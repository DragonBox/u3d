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
require 'u3d_core/core_ext/string'
require 'u3d/installation'
require 'fileutils'
require 'file-tail'

module U3d
  DEFAULT_LINUX_INSTALL = '/opt/'.freeze
  DEFAULT_MAC_INSTALL = '/'.freeze
  DEFAULT_WINDOWS_INSTALL = 'C:/Program Files/'.freeze
  UNITY_DIR = "Unity_%s".freeze
  UNITY_DIR_LINUX = "unity-editor-%s".freeze

  class Installer
    def self.create
      installer = if Helper.mac?
                    MacInstaller.new
                  elsif Helper.linux?
                    LinuxInstaller.new
                  else
                    WindowsInstaller.new
                  end
      sanitize_installs(installer)
      installer
    end

    def self.sanitize_installs(installer)
      return unless UI.interactive? || Helper.test?
      unclean = []
      installer.installed.each { |unity| unclean << unity unless unity.clean_install? }
      return if unclean.empty?
      UI.important("u3d can optionally standardize the existing Unity3d installation names and locations.")
      UI.important("Check the documentation for more information:")
      UI.important("** https://github.com/DragonBox/u3d/blob/master/README.md#default-installation-paths **")
      unclean.each { |unity| installer.sanitize_install(unity, dry_run: true) }
      return unless UI.confirm("#{unclean.count} Unity installation(s) will be moved. Proceed??")
      unclean.each { |unity| installer.sanitize_install(unity) }
    end

    def self.install_modules(files, version, installation_path: nil)
      installer = Installer.create
      files.each do |name, file, info|
        UI.verbose "Installing #{name}#{info['mandatory'] ? ' (mandatory package)' : ''}, with file #{file}"
        installer.install(file, version, installation_path: installation_path, info: info)
      end
    end
  end

  class CommonInstaller
    def self.sanitize_install(source_path, new_path, command, dry_run: false)
      if source_path == new_path
        UI.important "sanitize_install does nothing if the path won't change (#{source_path})"
        return
      end

      if dry_run
        UI.message "'#{source_path}' would move to '#{new_path}'"
      else
        UI.important "Moving '#{source_path}' to '#{new_path}'..."
        U3dCore::CommandExecutor.execute(command: command, admin: true)
        UI.success "Successfully moved '#{source_path}' to '#{new_path}'"
      end
    rescue => e
      UI.error "Unable to move '#{source_path}' to '#{new_path}': #{e}"
    end
  end

  class MacInstaller
    def sanitize_install(unity, dry_run: false)
      source_path = File.expand_path('..', unity.path)
      parent = File.expand_path('..', source_path)
      new_path = File.join(parent, UNITY_DIR % unity.version)
      source_path = source_path.shellescape
      new_path = new_path.shellescape

      command = "mv #{source_path} #{new_path}"

      CommonInstaller.sanitize_install(source_path, new_path, command, dry_run: dry_run)
    end

    def installed
      paths = (list_installed_paths + spotlight_installed_paths).uniq
      versions = paths.map { |path| MacInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    # rubocop:disable UnusedMethodArgument
    def install(file_path, version, installation_path: nil, info: {})
      # rubocop:enable UnusedMethodArgument
      extension = File.extname(file_path)
      raise "Installation of #{extension} files is not supported on Mac" if extension != '.pkg'
      path = installation_path || DEFAULT_MAC_INSTALL
      install_pkg(
        file_path,
        version: version,
        target_path: path
      )
    end

    def install_pkg(file_path, version: nil, target_path: nil)
      target_path ||= DEFAULT_MAC_INSTALL
      command = "installer -pkg #{file_path.shellescape} -target #{target_path.shellescape}"
      unity = installed.find { |u| u.version == version }
      temp_path = File.join(target_path, 'Applications', 'Unity')
      if unity.nil?
        UI.verbose "No Unity install for version #{version} was found"
        U3dCore::CommandExecutor.execute(command: command, admin: true)
        destination_path = File.join(target_path, 'Applications', UNITY_DIR % version)
        FileUtils.mv temp_path, destination_path
      else
        begin
          path = File.expand_path('..', unity.path)
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
    rescue => e
      UI.error "Failed to install pkg at #{file_path}: #{e}"
    else
      UI.success "Successfully installed package from #{file_path}"
    end

    private

    def list_installed_paths
      find = File.join(DEFAULT_MAC_INSTALL, 'Unity*', 'Unity.app')
      paths = Dir[find].map { |path| File.expand_path('..', path) }
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
      paths
    end
  end

  class LinuxInstaller
    def sanitize_install(unity, dry_run: false)
      source_path = File.expand_path(unity.path)
      parent = File.expand_path('..', source_path)
      new_path = File.join(parent, UNITY_DIR_LINUX % unity.version)
      source_path = source_path.shellescape
      new_path = new_path.shellescape

      command = "mv #{source_path} #{new_path}"

      CommonInstaller.sanitize_install(source_path, new_path, command, dry_run: dry_run)
    end

    def installed
      find = File.join(DEFAULT_LINUX_INSTALL, 'unity-editor-*')
      versions = Dir[find].map { |path| LinuxInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    # rubocop:disable UnusedMethodArgument
    def install(file_path, version, installation_path: nil, info: {})
      # rubocop:enable UnusedMethodArgument
      extension = File.extname(file_path)
      raise "Installation of #{extension} files is not supported on Linux" if extension != '.sh'
      path = installation_path || DEFAULT_LINUX_INSTALL
      install_sh(
        file_path,
        installation_path: path
      )
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
        unless File.directory? installation_path
          command = "mkdir -p #{installation_path.shellescape}; #{command}"
        end
        U3dCore::CommandExecutor.execute(command: command, admin: true)
      else
        U3dCore::CommandExecutor.execute(command: cmd, admin: true)
      end
    rescue => e
      UI.error "Failed to install bash file at #{file}: #{e}"
    else
      UI.success 'Installation successful'
    end
  end

  class WindowsInstaller
    def sanitize_install(unity, dry_run: false)
      source_path = File.expand_path(unity.path)
      parent = File.expand_path('..', source_path)
      new_path = File.join(parent, UNITY_DIR % unity.version)

      source_path.tr!('/', '\\')
      new_path.tr!('/', '\\')
      source_path = source_path.argescape
      new_path = new_path.argescape

      command = "move #{source_path} #{new_path}"

      CommonInstaller.sanitize_install(source_path, new_path, command, dry_run: dry_run)
    end

    def installed
      find = File.join(DEFAULT_WINDOWS_INSTALL, 'Unity*', 'Editor', 'Uninstall.exe')
      versions = Dir[find].map { |path| WindowsInstallation.new(path: File.expand_path('../..', path)) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def install(file_path, version, installation_path: nil, info: {})
      extension = File.extname(file_path)
      raise "Installation of #{extension} files is not supported on Windows" if extension != '.exe'
      path = installation_path || File.join(DEFAULT_WINDOWS_INSTALL, UNITY_DIR % version)
      install_exe(
        file_path,
        installation_path: path,
        info: info
      )
    end

    def install_exe(file_path, installation_path: nil, info: {})
      installation_path ||= DEFAULT_WINDOWS_INSTALL
      final_path = installation_path.tr('/', '\\')
      Utils.ensure_dir(final_path)
      begin
        command = nil
        if info['cmd']
          command = info['cmd']
          command.sub!(/{FILENAME}/, file_path)
          command.sub!(/{INSTDIR}/, final_path)
          command.sub!(/{DOCDIR}/, final_path)
          command.sub!(/{MODULEDIR}/, final_path)
          command.sub!(%r{\/D=}, '/S /D=') unless %r{\/S} =~ command
        end
        command ||= file_path.to_s
        U3dCore::CommandExecutor.execute(command: command, admin: true)
      rescue => e
        UI.error "Failed to install exe at #{file_path}: #{e}"
      else
        UI.success "Successfully installed #{info['title']}"
      end
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
