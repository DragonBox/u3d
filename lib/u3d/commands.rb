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
        installer = Installer.create
        installer.sanitize_installs
        list = installer.installed_sorted_by_versions
        if list.empty?
          UI.important 'No Unity version installed'
          return
        end
        list.each do |u|
          version_format = "Version %-15{version} [%<build_number>s] %<do_not_move>s(%<root_path>s)"
          do_not_move = u.do_not_move? ? '!'.red.bold : ' '
          h = { version: u.version, build_number: u.build_number, root_path: u.root_path, do_not_move: do_not_move }
          UI.message version_format % h
          packages = u.packages
          next unless options[:packages] && packages && !packages.empty?
          UI.message 'Packages:'
          packages.each { |pack| UI.message " - #{pack}" }
        end
      end

      # rubocop:disable Style/FormatStringToken
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
      # rubocop:enable Style/FormatStringToken

      def move(args: {}, options: {})
        long_name = options[:long]
        UI.user_error! "move only supports long version name for now" unless long_name

        version = args[0]
        UI.user_error! "Please specify a Unity version" unless version
        unity = check_unity_presence(version: version)
        if unity.nil?
          UI.message "Specified version '#{version}' not found."
          return
        end
        if unity.do_not_move?
          UI.error "Specified version is specicically marked as _do not move_."
          return
        end
        Installer.create.sanitize_install(unity, long: true, dry_run: options[:dry_run])

        unity.do_not_move!(dry_run: options[:dry_run]) # this may fail because of admin rights
      end

      def list_available(options: {})
        ver = options[:unity_version]
        os = valid_os_or_current(options[:operating_system])
        rl = options[:release_level]
        central = options.fetch(:central, true)

        cache_versions = cache_versions(os, force_refresh: options[:force], central_cache: central)

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

        show_packages = options[:packages]
        packages = UnityModule.load_modules(sorted_keys, cache_versions, os: os) if show_packages

        sorted_keys.each do |k|
          v = cache_versions[k]
          UI.message "Version #{k}: " + v.to_s.cyan.underline
          next unless show_packages
          version_packages = packages[k]
          UI.message 'Packages:'
          version_packages.each { |package| UI.message " - #{package.id.capitalize}" }
        end
      end

      def install(args: [], options: {})
        version = specified_or_current_project_version(args[0])

        UI.user_error!("You cannot use the --operating_system and the --install options together") if options[:install] && options[:operating_system]
        os = valid_os_or_current(options[:operating_system])

        cache_versions = cache_versions(os, offline: !options[:download])
        version = interpret_latest(version, cache_versions)
        unless cache_versions[version]
          UI.crash! "No version '#{version}' was found in cache. Either it doesn't exist or u3d doesn't know about it yet. Try refreshing with 'u3d available -f'"
          return
        end

        definition = UnityVersionDefinition.new(version, os, cache_versions)
        unity = check_unity_presence(version: version)

        packages = verify_package_names(options[:packages], definition) || ['Unity']

        begin
          packages = enforce_setup_coherence(packages, options, unity, definition)
        rescue InstallationSetupError
          return
        end

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
          extra_run_args = ['-projectPath', up.path]
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

      def cache_versions(os, offline: false, force_refresh: false, central_cache: true)
        cache = Cache.new(force_os: os, offline: offline, force_refresh: force_refresh, central_cache: central_cache)
        cache_os = cache[os.id2name] || {}
        cache_versions = cache_os['versions'] || {}
        cache_versions
      end

      def verify_package_names(packages, definition)
        unless packages.nil?
          invalid_packages = packages.reject { |package| definition.available_package? package }
          raise ArgumentError, "Package(s) '#{invalid_packages.join(',')}' are not known. Use #{definition.available_packages.join(',')}" unless invalid_packages.empty?
        end
        packages
      end

      def specified_or_current_project_version(version)
        unless version # no version specified, use the one from the current unity project if any
          UI.message "No unity version specified. If the current directory is a Unity project, we try to install the one it requires"
          up = UnityProject.new(Dir.pwd)
          version = up.editor_version if up.exist?
        end
        UI.user_error!('Please specify a Unity version') unless version
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
        packages = sort_packages(packages, definition)
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
            # FIXME: unity.package_installed? is not reliable
            packages = detect_installed_packages(packages, unity)
            packages = detect_missing_dependencies(packages, unity, definition)
            raise InstallationSetupError if packages.empty?
          else
            unless packages.map(&:downcase).include?('unity')
              UI.error 'Please install Unity before any of its packages'
              raise InstallationSetupError
            end
          end
        end
        packages
      end
      # rubocop:enable Metrics/BlockNesting

      def sort_packages(packages, definition)
        packages.sort do |a, b|
          package_a = definition[a]
          package_b = definition[b]
          if package_a.depends_on?(package_b) # b must come first
            1
          elsif package_b.depends_on?(package_a) # a must come first
            -1
          else
            a <=> b # Resort to alphabetical sorting
          end
        end
      end

      def detect_installed_packages(packages, unity)
        result = packages
        packages.select { |pack| unity.package_installed?(pack) }.each do |pack|
          result.delete pack
          UI.important "Ignoring #{pack} module, it is already installed"
        end
        result
      end

      def detect_missing_dependencies(packages, unity, definition)
        result = packages
        packages.reject { |package| can_install?(package, unity, definition, packages) }.each do |pack|
          # See FIXME for package_installed?
          # result.delete pack
          package = definition[pack]
          UI.important "#{package.name} depends on #{package.depends_on}, but it's neither installed nor being installed."
        end
        result
      end

      def can_install?(package_name, unity, definition, installing)
        package = definition[package_name]
        return true unless package.depends_on
        return true if unity.package_installed?(package.depends_on)
        installing.map { |other| definition[other] }.any? do |other|
          other.id == package.depends_on || other.name == package.depends_on
        end
      end

      def get_administrative_privileges(options)
        U3dCore::Globals.use_keychain = true if options[:keychain] && Helper.mac?
        UI.important 'Root privileges are required'
        raise 'Could not get administrative privileges' unless U3dCore::CommandExecutor.has_admin_privileges?
      end
    end
  end
  # rubocop:enable ClassLength
end

class InstallationSetupError < StandardError
end
