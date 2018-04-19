## --- BEGIN LICENSE BLOCK ---
# Copyright (c) 2016-present WeWantToKnow AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
## --- END LICENSE BLOCK ---

require 'u3d_core/core_ext/hash'
require 'u3d/compatibility'
require 'u3d/unity_versions'
require 'u3d/unity_version_definition'
require 'u3d/downloader'
require 'u3d/installer'
require 'u3d/unity_project'
require 'u3d/cache'
require 'u3d/utils'
require 'u3d/log_analyzer'
require 'u3d/unity_runner'
require 'u3d_core/command_executor'
require 'u3d_core/credentials'
require 'fileutils'

module U3d
  # API for U3d, redirecting calls to class they concern
  # rubocop:disable ClassLength
  class Commands
    using ::CoreExtensions::Extractable

    class << self
      def list_installed(options: {})
        list = Installer.create.installed
        if list.empty?
          UI.important 'No Unity version installed'
          return
        end
        # version -> installations
        arraym = list.map { |a| [a.version, a] }
        map = Hash[*arraym.flatten]
        # sorted versions
        vcomparators = map.keys.map { |k| UnityVersionComparator.new(k) }
        sorted_keys = vcomparators.sort.map { |v| v.version.to_s }
        sorted_keys.map { |k| map[k] }.each do |u|
          version_format = "Version %-15{version} [%<build_number>s]  (%<root_path>s)"
          h = { version: u.version, build_number: u.build_number, root_path: u.root_path }
          UI.message version_format % h
          packages = u.packages
          next unless options[:packages] && packages && !packages.empty?
          UI.message 'Packages:'
          packages.each { |pack| UI.message " - #{pack}" }
        end
      end

      def console
        require 'irb'
        ARGV.clear
        IRB.setup(nil)
        @irb = IRB::Irb.new(nil)
        IRB.conf[:MAIN_CONTEXT] = @irb.context
        IRB.conf[:PROMPT][:U3D] = IRB.conf[:PROMPT][:SIMPLE].dup
        IRB.conf[:PROMPT][:U3D][:RETURN] = "%s\n"
        @irb.context.prompt_mode = :U3D
        @irb.context.workspace = IRB::WorkSpace.new(binding)
        trap 'INT' do
          @irb.signal_handle
        end

        UI.message('Welcome to u3d interactive!')

        catch(:IRB_EXIT) { @irb.eval_input }
      end

      def list_available(options: {})
        ver = options[:unity_version]
        os = valid_os_or_current(options[:operating_system])
        rl = options[:release_level]

        cache_versions = cache_versions(os, force_refresh: options[:force])

        if ver
          cache_versions = cache_versions.extract(*cache_versions.keys.select { |k| Regexp.new(ver).match(k) })
          return UI.error "Version #{ver} doesn't match any in cache" if cache_versions.empty?
        end

        vcomparators = cache_versions.keys.map { |k| UnityVersionComparator.new(k) }
        if rl
          letter = release_letter_mapping["latest_#{rl}".to_sym]
          UI.message "Filtering available versions with release level '#{rl}' [letter '#{letter}']"
          vcomparators.select! { |vc| vc.version.parts[3] == letter }
        end
        sorted_keys = vcomparators.sort.map { |v| v.version.to_s }

        sorted_keys.each do |k|
          v = cache_versions[k]
          UI.message "Version #{k}: " + v.to_s.cyan.underline
          next unless options[:packages]
          inif = nil
          begin
            inif = U3d::INIparser.load_ini(k, cache_versions, os: os)
          rescue StandardError => e
            UI.error "Could not load packages for this version (#{e})"
          else
            UI.message 'Packages:'
            inif.each_key { |pack| UI.message " - #{pack}" }
          end
        end
      end

      def install(args: [], options: {})
        version = specified_or_current_project_version(args[0])

        UI.user_error!("You cannot use the --operating_system and the --install options together") if options[:install] && options[:operating_system]
        os = valid_os_or_current(options[:operating_system])

        packages = packages_with_unity_first(options)

        cache_versions = cache_versions(os, offline: !options[:download])
        version = interpret_latest(version, cache_versions)
        unless cache_versions[version]
          UI.error "No version '#{version}' was found in cache. Either it doesn't exist or u3d doesn't know about it yet. Try refreshing with 'u3d available -f'"
          return
        end

        definition = UnityVersionDefinition.new(version, os, cache_versions)
        unity = check_unity_presence(version: version)
        return unless enforce_setup_coherence(packages, options, unity, definition)

        verify_package_names(definition, packages)

        get_administrative_privileges(options) if options[:install]

        files = Downloader.fetch_modules(definition, packages: packages, download: options[:download])

        return unless options[:install]
        Installer.install_modules(files, definition.version, installation_path: options[:installation_path])
      end

      def uninstall(args: [], options: [])
        version = specified_or_current_project_version(args[0])

        unity = check_unity_presence(version: version)

        UI.user_error!("Unity version #{version} is not present and cannot be uninstalled") unless unity

        get_administrative_privileges(options)

        Installer.uninstall(unity: unity)
      end

      def install_dependencies
        unless Helper.linux?
          UI.important 'u3d dependencies is Linux-only, and not needed on other OS'
          return
        end

        LinuxDependencies.install
      end

      def run(options: {}, run_args: [])
        version = options[:unity_version]

        runner = Runner.new
        args_pp = Runner.find_projectpath_in_args(run_args)
        pp = args_pp
        pp ||= Dir.pwd
        up = UnityProject.new(pp)

        unless version # fall back in project default if we are on a Unity project
          version = up.editor_version if up.exist?
          UI.user_error!('Not sure which version of Unity to run. Are you in a Unity5 or later project?') unless version
        end

        if up.exist? && args_pp.nil?
          extra_run_args = ['-projectpath', up.path]
          run_args = [extra_run_args, run_args].flatten
        end

        unity = check_unity_presence(version: version)
        UI.user_error! "Unity version '#{version}' not found" unless unity
        runner.run(unity, run_args, raw_logs: options[:raw_logs])
      end

      def credentials_actions
        %w[add remove check]
      end

      def credentials(args: [])
        action = args[0]
        raise "Please specify an action to perform, one of #{credentials_actions.join(',')}" unless action
        raise "Unknown action '#{action}'. Use one of #{credentials_actions.join(',')}" unless credentials_actions.include? action
        if action == 'add'
          U3dCore::Globals.use_keychain = true
          # credentials = U3dCore::Credentials.new(user: ENV['USER'])
          # credentials.login # ask password
          UI.error 'Invalid credentials' unless U3dCore::CommandExecutor.has_admin_privileges?
        elsif action == 'remove'
          U3dCore::Globals.use_keychain = true
          U3dCore::Credentials.new(user: ENV['USER']).forget_credentials(force: true)
        else
          credentials_check
        end
      end

      def licenses
        U3d::License.licenses.sort_by { |l| l['LicenseVersion'] }.each do |license|
          UI.message "#{license.path}: #{license['LicenseVersion']} #{license.number} #{license['UpdateDate']}"
        end
      end

      def local_analyze(args: [])
        raise ArgumentError, 'No files given' if args.empty?
        raise ArgumentError, "File #{args[0]} does not exist" unless File.exist? args[0]

        analyzer = LogAnalyzer.new
        File.open(args[0], 'r') do |f|
          f.readlines.each { |l| analyzer.parse_line l }
        end
      end

      def release_levels
        %i[stable beta patch]
      end

      def release_letter_mapping
        {
          latest: 'f',
          latest_stable: 'f',
          latest_beta: 'b',
          latest_patch: 'p'
        }
      end

      private

      def cache_versions(os, offline: false, force_refresh: false)
        cache = Cache.new(force_os: os, offline: offline, force_refresh: force_refresh, central_cache: true)
        cache_os = cache[os.id2name] || {}
        cache_versions = cache_os['versions'] || {}
        cache_versions
      end

      def verify_package_names(definition, packages)
        packages.each do |package|
          UI.user_error! "package '#{package}' doesn't exist" unless definition.available_package? package
        end
      end

      def specified_or_current_project_version(version)
        unless version # no version specified, use the one from the current unity project if any
          UI.message "No unity version specified. If the current directory is a Unity project, we try to install the one it requires"
          up = UnityProject.new(Dir.pwd)
          version = up.editor_version if up.exist?
        end
        UI.user_error!('Please specify a Unity version to download') unless version
        version
      end

      def credentials_check
        U3dCore::Globals.use_keychain = true
        credentials = U3dCore::Credentials.new(user: ENV['USER'])
        U3dCore::Globals.with_do_not_login(true) do
          if credentials.password.to_s.empty?
            UI.message "No credentials stored"
          elsif U3dCore::CommandExecutor.has_admin_privileges?
            UI.success "Stored credentials are valid"
          else
            UI.error "Stored credentials are not valid"
          end
        end
        # FIXME: return value
      end

      # if the specified string representatio of `os` is non nil
      # convert the it to a symbol and checks it against the valid ones
      # or return the current OS
      def valid_os_or_current(os)
        if os
          os = os.to_sym
          oses = U3dCore::Helper.operating_systems
          raise "Specified OS (#{os}) isn't valid [#{oses.join(', ')}]" unless oses.include?(os)
        else
          os = U3dCore::Helper.operating_system
        end
        os
      end

      def interpret_latest(version, versions)
        return version unless release_letter_mapping.keys.include? version.to_sym

        letter = release_letter_mapping[version.to_sym]

        iversion = versions.keys.map { |k| UnityVersionComparator.new(k) }
                           .sort
                           .reverse
                           .find { |c| c.version.parts[3] == letter }
                           .version.to_s
        UI.message "Version '#{version}' is #{iversion}."
        iversion
      end

      def packages_with_unity_first(options)
        temp = options[:packages] || ['Unity']
        temp.insert(0, 'Unity') if temp.delete('Unity')
        temp
      end

      def check_unity_presence(version: nil)
        # idea: we could support matching 5.3.6p3 if passed 5.3.6
        installed = Installer.create.installed
        unity = installed.find { |u| u.version == version }
        if unity.nil?
          UI.verbose "Version #{version} of Unity is not installed yet"
        else
          UI.verbose "Unity #{version} is installed at #{unity.root_path}"
          return unity
        end
        nil
      end

      # rubocop:disable Metrics/BlockNesting
      def enforce_setup_coherence(packages, options, unity, definition)
        if options[:all]
          packages.clear
          packages.concat(definition.available_packages)
        end
        if options[:install]
          if unity
            UI.important "Unity #{unity.version} is already installed"
            # Not needed since Linux custom u3d files contain only one entry wich is Unity
            # return false if definition.os == :linux
            if packages.include?('Unity')
              UI.important 'Ignoring Unity module, it is already installed'
              packages.delete('Unity')

              # FIXME: Move me to the WindowsInstaller
              options[:installation_path] ||= unity.root_path if definition.os == :win
            end
            packages.select { |pack| unity.package_installed?(pack) }.each do |pack|
              packages.delete pack
              UI.important "Ignoring #{pack} module, it is already installed"
            end
            return false if packages.empty?
          else
            unless packages.include?('Unity')
              UI.error 'Please install Unity before any of its packages'
              return false
            end
          end
        end
        true
      end
      # rubocop:enable Metrics/BlockNesting

      def get_administrative_privileges(options)
        U3dCore::Globals.use_keychain = true if options[:keychain] && Helper.mac?
        UI.important 'Root privileges are required'
        raise 'Could not get administrative privileges' unless U3dCore::CommandExecutor.has_admin_privileges?
      end
    end
  end
  # rubocop:enable ClassLength
end
