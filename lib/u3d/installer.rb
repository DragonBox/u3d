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

require 'u3d/utils'
require 'u3d_core/admin_tools'
require 'u3d_core/core_ext/string'
require 'u3d/installation'
require 'fileutils'
require 'file-tail'
require 'pathname'

module U3d
  DEFAULT_LINUX_INSTALL = '/opt/'.freeze
  DEFAULT_MAC_INSTALL = '/Applications/'.freeze
  DEFAULT_WINDOWS_INSTALL = 'C:/Program Files/'.freeze

  UNITY_DIR = "Unity_%<version>s".freeze
  UNITY_DIR_LONG = "Unity_%<version>s_%<build_number>s".freeze
  UNITY_DIR_LINUX = "unity-editor-%<version>s".freeze
  UNITY_DIR_LINUX_LONG = "unity-editor-%<version>s_%<build_number>s".freeze

  class Installer
    def self.create
      if Helper.mac?
        MacInstaller.new
      elsif Helper.linux?
        LinuxInstaller.new
      else
        WindowsInstaller.new
      end
    end

    def self.sanitize_installs(installer)
      installer.sanitize_installs
    end

    def self.install_modules(files, version, installation_path: nil)
      installer = Installer.create
      files.each do |name, file, info|
        UI.header "Installing #{info['title']} (#{name})"
        UI.message 'Installing with ' + file
        installer.install(file, version, installation_path: installation_path, info: info)
      end
    end

    def self.uninstall(unity: nil)
      installer = Installer.create
      installer.uninstall(unity: unity)
    end
  end

  class BaseInstaller
    DEFAULT_PLATFORM_INSTALL_PATH = {
      linux: DEFAULT_LINUX_INSTALL,
      win: DEFAULT_WINDOWS_INSTALL,
      mac: DEFAULT_MAC_INSTALL
    }

    def initialize(platform: nil) # nil for bacward compatibility. Is really required
      @platform = platform
    end

    def install_directory(default_only: false)
      path = default_only ? DEFAULT_PLATFORM_INSTALL_PATH[@platform] : ENV['U3D_INSTALL_PATH'] || DEFAULT_PLATFORM_INSTALL_PATH[@platform]
      File.expand_path(path)
    end

    def sanitize_installs
      return unless UI.interactive? || Helper.test?
      unclean = []
      installed.each { |unity| unclean << unity unless unity.clean_install? }
      return if unclean.empty?
      UI.important("u3d can optionally standardize the existing Unity installation names and locations.")
      UI.important("Check the documentation for more information:")
      UI.important("** https://github.com/DragonBox/u3d/blob/master/README.md#default-installation-paths **")
      unclean.each { |unity| sanitize_install(unity, dry_run: true) }
      return unless UI.confirm("#{unclean.count} Unity installation(s) will be moved. Proceed??")
      unclean.each { |unity| sanitize_install(unity) }
    end

    def installed_sorted_by_versions
      list = installed
      return [] if list.empty?
      # version -> installations
      arraym = list.map { |a| [a.version, a] }
      map = Hash[*arraym.flatten]
      # sorted versions
      vcomparators = map.keys.map { |k| UnityVersionComparator.new(k) }
      sorted_keys = vcomparators.sort.map { |v| v.version.to_s }
      sorted_keys.map { |k| map[k] }
    end
  end

  # deprecated
  class CommonInstaller
    def self.sanitize_install(source_path, new_path, command, dry_run: false)
      UI.deprecated("Use U3dCore::AdminTools.move_files")
      U3dCore::AdminTools.move_file(source_path, new_path, command, dry_run: dry_run)
    end
  end

  class MacInstaller < BaseInstaller
    def initialize
      super(platform: :mac)
    end

    def sanitize_install(unity, long: false, dry_run: false)
      source_path = unity.root_path
      parent = File.expand_path('..', source_path)
      dir_name = format(long ? UNITY_DIR_LONG : UNITY_DIR,
                        version: unity.version, build_number: unity.build_number)
      new_path = File.join(parent, dir_name)

      moved = U3dCore::AdminTools.move_os_file(:mac, source_path, new_path, dry_run: dry_run)
      unity.root_path = new_path if moved && !dry_run
    end

    def installed
      paths = (list_installed_paths + spotlight_installed_paths).uniq
      paths.map { |path| MacInstallation.new(root_path: path) }
    end

    # rubocop:disable UnusedMethodArgument
    def install(file_path, version, installation_path: nil, info: {})
      # rubocop:enable UnusedMethodArgument
      extension = File.extname(file_path)
      raise "Installation of #{extension} files is not supported on Mac" if extension != '.pkg'
      path = installation_path || install_directory
      install_pkg(
        file_path,
        version: version,
        installation_path: path
      )
    end

    # FIXME: we don't support target_path anymore
    def install_pkg(file_path, version: nil, installation_path: nil)
      target_path = '/'
      command = "installer -pkg #{file_path.shellescape} -target #{target_path.shellescape}"
      unity = installed.find { |u| u.version == version }
      temp_path = File.join(installation_path, 'Unity')
      if unity.nil?
        UI.verbose "No Unity install for version #{version} was found"
        U3dCore::CommandExecutor.execute(command: command, admin: true)
        destination_path = File.join(install_directory, format(UNITY_DIR, version: version))
        FileUtils.mv temp_path, destination_path
      else
        UI.verbose "Unity install for version #{version} found under #{unity.root_path}"
        begin
          path = unity.root_path
          move_to_temp = (temp_path != path)
          if move_to_temp
            UI.verbose "Temporary switching location of #{path} to #{temp_path} for installation purpose"
            FileUtils.mv path, temp_path
          end
          U3dCore::CommandExecutor.execute(command: command, admin: true)
        ensure
          FileUtils.mv temp_path, path if move_to_temp
        end
      end
    rescue StandardError => e
      UI.error "Failed to install pkg at #{file_path}: #{e}"
    else
      UI.success "Successfully installed package from #{file_path}"
    end

    def uninstall(unity: nil)
      UI.verbose("Uninstalling Unity at '#{unity.root_path}'...")
      command = "rm -r #{unity.root_path.argescape}"
      U3dCore::CommandExecutor.execute(command: command, admin: true)
    rescue StandardError => e
      UI.error "Failed to uninstall unity at #{unity.path}: #{e}"
    else
      UI.success "Successfully uninstalled '#{unity.root_path}'"
    end

    private

    def list_installed_paths
      find = File.join(install_directory, 'Unity*', 'Unity.app')
      paths = Dir[find]
      paths = paths.map { |u| Pathname.new(u).parent.to_s }
      UI.verbose "Found list_installed_paths: #{paths}"
      paths
    end

    def spotlight_installed_paths
      unless (`mdutil -s /` =~ /disabled/).nil?
        UI.important 'Please enable Spotlight indexing for /Applications.'
        return []
      end

      bundle_identifiers = ['com.unity3d.UnityEditor4.x', 'com.unity3d.UnityEditor5.x']

      mdfind_args = bundle_identifiers.map { |bi| "kMDItemCFBundleIdentifier == '#{bi}'" }.join(' || ')

      cmd = "mdfind \"#{mdfind_args}\" 2>/dev/null"
      UI.verbose cmd
      paths = `#{cmd}`.split("\n")
      paths = paths.map { |u| Pathname.new(u).parent.to_s }
      UI.verbose "Found spotlight_installed_paths: #{paths}"
      paths
    end
  end

  # rubocop:disable ClassLength
  class LinuxInstaller < BaseInstaller
    def initialize
      super(platform: :linux)
    end

    def sanitize_install(unity, long: false, dry_run: false)
      source_path = File.expand_path(unity.root_path)
      parent = File.expand_path('..', source_path)
      dir_name = format(long ? UNITY_DIR_LINUX_LONG : UNITY_DIR_LINUX,
                        version: unity.version, build_number: unity.build_number)
      new_path = File.join(parent, dir_name)

      moved = U3dCore::AdminTools.move_os_file(:linux, source_path, new_path, dry_run: dry_run)
      unity.root_path = new_path if moved && !dry_run
    end

    def installed
      paths = (list_installed_paths + debian_installed_paths).uniq
      paths.map { |path| LinuxInstallation.new(root_path: path) }
    end

    # rubocop:disable UnusedMethodArgument, PerceivedComplexity
    def install(file_path, version, installation_path: nil, info: {})
      # rubocop:enable UnusedMethodArgument, PerceivedComplexity
      extension = File.extname(file_path)

      raise "Installation of #{extension} files is not supported on Linux" unless ['.sh', '.xz', '.pkg'].include? extension
      if extension == '.sh'
        path = installation_path || install_directory
        install_sh(file_path, installation_path: path)
      elsif extension == '.xz'
        new_path = File.join(install_directory, format(UNITY_DIR_LINUX, version: version))
        path = installation_path || new_path
        install_xz(file_path, installation_path: path)
      elsif extension == '.pkg'
        new_path = File.join(install_directory, format(UNITY_DIR_LINUX, version: version))
        path = installation_path || new_path
        install_pkg(file_path, installation_path: path)
      end

      # Forces sanitation for installation of 'weird' versions eg 5.6.1xf1Linux
      unity = installed.select { |u| u.version == version }.first
      if unity
        sanitize_install(unity)
      else
        UI.error "Unity was not installed properly"
      end
    end

    def install_sh(file, installation_path: nil)
      cmd = file.shellescape

      U3dCore::CommandExecutor.execute(command: "chmod a+x #{cmd}")

      if installation_path
        command = "cd #{installation_path.shellescape}; #{cmd}"
        command = "mkdir -p #{installation_path.shellescape}; #{command}" unless File.directory? installation_path
        U3dCore::CommandExecutor.execute(command: command, admin: true)
      else
        U3dCore::CommandExecutor.execute(command: cmd, admin: true)
      end
    rescue StandardError => e
      UI.error "Failed to install sh file #{file} at #{installation_path}: #{e}"
    else
      UI.success 'Installation successful'
    end

    def install_xz(file, installation_path: nil)
      raise 'Missing installation_path' unless installation_path

      command = "cd #{installation_path.shellescape}; tar xf #{file.shellescape}"
      command = "mkdir -p #{installation_path.shellescape}; #{command}" unless File.directory? installation_path
      U3dCore::CommandExecutor.execute(command: command, admin: true)
    rescue StandardError => e
      UI.error "Failed to install xz file #{file} at #{installation_path}: #{e}"
    else
      UI.success 'Installation successful'
    end

    def install_pkg(file, installation_path: nil)
      raise 'Missing installation_path' unless installation_path
      raise 'Only able to install pkg on top of existing Unity installs' unless File.exist? installation_path
      raise 'Missing 7z' if `which 7z`.empty?

      Dir.mktmpdir do |tmp_dir|
        UI.verbose "Working in tmp dir #{tmp_dir}"

        command = "7z -aos -o#{tmp_dir.shellescape} e #{file.shellescape}"
        U3dCore::CommandExecutor.execute(command: command)

        target_location = pkg_install_path(installation_path, "#{tmp_dir}/PackageInfo")

        # raise "Path for #{target_location} already exists" if path File.exist? target_location

        command = "cd #{target_location.shellescape}; gzip -dc #{tmp_dir}/Payload | cpio -i '*' -"
        command = "mkdir -p #{target_location.shellescape}; #{command}" # unless File.directory? installation_path

        U3dCore::CommandExecutor.execute(command: command, admin: true)
      end
    rescue StandardError => e
      UI.verbose(e.backtrace.join("\n"))
      UI.error "Failed to install pkg file #{file} at #{installation_path}: #{e}"
    else
      UI.success 'Installation successful'
    end

    def uninstall(unity: nil)
      UI.verbose("Uninstalling Unity at '#{unity.root_path}'...")
      command = "rm -r #{unity.root_path}"
      U3dCore::CommandExecutor.execute(command: command, admin: true)
    rescue StandardError => e
      UI.error "Failed to uninstall unity at #{unity.path}: #{e}"
    else
      UI.success "Successfully uninstalled '#{unity.root_path}'"
    end

    private

    def pkg_install_path(unity_root_path, pinfo_path)
      raise "PackageInfo not found under #{pinfo_path}" unless File.exist? pinfo_path
      pinfo = File.read(pinfo_path)
      require 'rexml/document'
      d = REXML::Document.new(pinfo)
      identifier = d.root.attributes['identifier']

      case identifier
      when 'com.unity3d.Documentation'
        "#{unity_root_path}/Editor/Data/"
      when 'com.unity3d.StandardAssets'
        "#{unity_root_path}/Editor/Standard Assets/"
      when 'com.unity3d.ExampleProject'
        unity_root_path
      else
        install_location = d.root.attributes['install-location']
        raise "Not sure how to install this module with identifier #{identifier} install-location: #{install_location}" unless install_location.start_with? '/Applications/Unity/'
        install_location.gsub(%(\/Applications\/Unity), "#{unity_root_path}/Editor/Data")
      end
    end

    def list_installed_paths
      find = File.join(install_directory, 'unity-editor-*', 'Editor')
      paths = Dir[find]
      paths = paths.map { |u| Pathname.new(u).parent.to_s }
      UI.verbose "Found list_installed_paths: #{paths}"
      paths
    end

    def debian_installed_paths
      find = File.join(DEFAULT_LINUX_INSTALL, 'Unity', 'Editor')
      paths = Dir[find]
      paths = paths.map { |u| Pathname.new(u).parent.to_s }
      UI.verbose "Found debian_installed_paths: #{paths}"
      paths
    end
  end
  # rubocop:enable ClassLength

  class WindowsInstaller < BaseInstaller
    def initialize
      super(platform: :win)
    end

    def sanitize_install(unity, long: false, dry_run: false)
      source_path = File.expand_path(unity.root_path)
      parent = File.expand_path('..', source_path)
      dir_name = format(long ? UNITY_DIR_LONG : UNITY_DIR,
                        version: unity.version, build_number: unity.build_number)
      new_path = File.join(parent, dir_name)

      moved = U3dCore::AdminTools.move_os_file(:win, source_path, new_path, dry_run: dry_run)
      unity.root_path = new_path if moved && !dry_run
    end

    def installed
      find = File.join(install_directory, 'Unity*', 'Editor', 'Uninstall.exe')
      Dir[find].map { |path| WindowsInstallation.new(root_path: File.expand_path('../..', path)) }
    end

    def install(file_path, version, installation_path: nil, info: {})
      extension = File.extname(file_path)
      raise "Installation of #{extension} files is not supported on Windows" unless %w[.exe .msi].include? extension
      path = installation_path || File.join(install_directory, format(UNITY_DIR, version: version))
      install_exe(
        file_path,
        installation_path: path,
        info: info
      )
    end

    def install_exe(file_path, installation_path: nil, info: {})
      installation_path ||= install_directory
      final_path = U3dCore::Helper.windows_path(installation_path)
      Utils.ensure_dir(final_path)
      begin
        command = nil
        if info['cmd']
          command = info['cmd']
          if /msiexec/ =~ command
            command.sub!(/{FILENAME}/, '"' + U3dCore::Helper.windows_path(file_path) + '"')
          else
            command.sub!(/{FILENAME}/, file_path.argescape)
          end
          command.sub!(/{INSTDIR}/, final_path)
          command.sub!(/{DOCDIR}/, final_path)
          command.sub!(/{MODULEDIR}/, final_path)
          command.sub!(%r{\/D=}, '/S /D=') unless %r{\/S} =~ command
        end
        command ||= file_path.argescape
        U3dCore::CommandExecutor.execute(command: command, admin: true)
      rescue StandardError => e
        UI.error "Failed to install package at #{file_path}: #{e}"
      else
        UI.success "Successfully installed #{info['title']}"
      end
    end

    def uninstall(unity: nil)
      UI.verbose("Uninstalling Unity at '#{unity.root_path}'...")
      uninstall_exe = File.join(unity.root_path, 'Editor', 'Uninstall.exe')
      command = "#{uninstall_exe.argescape} /S"
      UI.message("Although the uninstall process completed, it takes a few seconds before the files are actually removed")
      U3dCore::CommandExecutor.execute(command: command, admin: true)
    rescue StandardError => e
      UI.error "Failed to uninstall unity at #{unity.path}: #{e}"
    else
      UI.success "Successfully uninstalled '#{unity.root_path}'"
    end
  end

  class LinuxDependencies
    # see https://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/
    DEPENDENCIES = [
      'gconf-service',
      'lib32gcc1',
      'lib32stdc++6',
      'libasound2',
      'libc6',
      'libc6-i386',
      'libcairo2',
      'libcap2',
      'libcups2',
      'libdbus-1-3',
      'libexpat1',
      'libfontconfig1',
      'libfreetype6',
      'libgcc1',
      'libgconf-2-4',
      'libgdk-pixbuf2.0-0',
      'libgl1-mesa-glx',
      'libglib2.0-0',
      'libglu1-mesa',
      'libgtk2.0-0',
      'libnspr4',
      'libnss3',
      'libpango1.0-0',
      'libstdc++6',
      'libx11-6',
      'libxcomposite1',
      'libxcursor1',
      'libxdamage1',
      'libxext6',
      'libxfixes3',
      'libxi6',
      'libxrandr2',
      'libxrender1',
      'libxtst6',
      'zlib1g',
      'debconf',
      'npm',
      'libpq5' # missing from original list
    ].freeze

    def self.install
      if `which dpkg` != ''
        prefix = 'apt-get -y install'
      elsif `which rpm` != ''
        prefix = 'yum -y install'
      else
        raise 'Cannot install dependencies on your Linux distribution'
      end

      if UI.interactive?
        return unless UI.confirm "Install dependencies? (#{DEPENDENCIES.length} dependency(ies) to install)"
      end
      U3dCore::CommandExecutor.execute(command: "#{prefix} #{DEPENDENCIES.join(' ')}", admin: true)
    end
  end
end
