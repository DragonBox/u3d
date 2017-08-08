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
require 'fileutils'
require 'file-tail'

# Mac specific only right now
module U3d
  DEFAULT_LINUX_INSTALL = '/opt/'.freeze
  DEFAULT_MAC_INSTALL = '/'.freeze
  DEFAULT_WINDOWS_INSTALL = 'C:/Program Files/'.freeze
  UNITY_DIR = "Unity_%s".freeze
  UNITY_DIR_LINUX = "unity-editor-%s".freeze
  UNITY_DIR_CHECK = /Unity_\d+\.\d+\.\d+[a-z]\d+/
  UNITY_DIR_CHECK_LINUX = /unity-editor-\d+\.\d+\.\d+[a-z]\d+\z/

  class Installation
    def self.create(path: nil)
      if Helper.mac?
        MacInstallation.new path
      elsif Helper.linux?
        LinuxInstallation.new path
      else
        WindowsInstallation.new path
      end
    end
  end

  class MacInstallation < Installation
    attr_reader :path

    require 'plist'

    def initialize(path: nil)
      @path = path
    end

    def version
      plist['CFBundleVersion']
    end

    def default_log_file
      "#{ENV['HOME']}/Library/Logs/Unity/Editor.log"
    end

    def exe_path
      "#{path}/Contents/MacOS/Unity"
    end

    def packages
      if Utils.parse_unity_version(version)[0].to_i <= 4
        # Unity < 5 doesn't have packages
        return []
      end
      fpath = File.expand_path('../PlaybackEngines', path)
      raise "Unity installation does not seem correct. Couldn't locate PlaybackEngines." unless Dir.exist? fpath
      Dir.entries(fpath).select { |e| File.directory?(File.join(fpath, e)) && !(e == '.' || e == '..') }
    end

    def clean_install?
      path =~ UNITY_DIR_CHECK
    end

    private

    def plist
      @plist ||= Plist.parse_xml("#{@path}/Contents/Info.plist")
    end
  end

  class LinuxInstallation < Installation
    attr_reader :path

    def initialize(path: nil)
      @path = path
    end

    def version
      # I don't find an easy way to extract the version on Linux
      require 'rexml/document'
      fpath = "#{path}/Editor/Data/PlaybackEngines/LinuxStandaloneSupport/ivy.xml"
      raise "Couldn't find file #{fpath}" unless File.exist? fpath
      doc = REXML::Document.new(File.read(fpath))
      version = REXML::XPath.first(doc, 'ivy-module/info/@e:unityVersion').value
      if (m = version.match(/^(.*)x(.*)Linux$/))
        version = "#{m[1]}#{m[2]}"
      end
      version
    end

    def default_log_file
      "#{ENV['HOME']}/.config/unity3d/Editor.log"
    end

    def exe_path
      "#{path}/Editor/Unity"
    end

    def packages
      false
    end

    def clean_install?
      path =~ UNITY_DIR_CHECK_LINUX
    end
  end

  class WindowsInstallation < Installation
    attr_reader :path

    def initialize(path: nil)
      @path = path
    end

    def version
      require 'rexml/document'
      fpath = "#{path}/Editor/Data/PlaybackEngines/windowsstandalonesupport/ivy.xml"
      raise "Couldn't find file #{fpath}" unless File.exist? fpath
      doc = REXML::Document.new(File.read(fpath))
      version = REXML::XPath.first(doc, 'ivy-module/info/@e:unityVersion').value

      version
    end

    def default_log_file
      if @logfile.nil?
        begin
          loc_appdata = Utils.windows_local_appdata
          log_dir = File.expand_path('Unity/Editor/', loc_appdata)
          UI.important "Log directory (#{log_dir}) does not exist" unless Dir.exist? log_dir
          @logfile = File.expand_path('Editor.log', log_dir)
        rescue RuntimeError => ex
          UI.error "Unable to retrieve the editor logfile: #{ex}"
        end
      end
      @logfile
    end

    def exe_path
      File.join(@path, 'Editor', 'Unity.exe')
    end

    def packages
      # Unity prior to Unity5 did not have package
      return [] if Utils.parse_unity_version(version)[0].to_i <= 4
      fpath = "#{path}/Editor/Data/PlaybackEngines/"
      raise "Unity installation does not seem correct. Couldn't locate PlaybackEngines." unless Dir.exist? fpath
      Dir.entries(fpath).select { |e| File.directory?(File.join(fpath, e)) && !(e == '.' || e == '..') }
    end

    def clean_install?
      path =~ UNITY_DIR_CHECK
    end
  end

  class Installer
    def self.create
      installer = if Helper.mac?
                    MacInstaller.new
                  elsif Helper.linux?
                    LinuxInstaller.new
                  else
                    WindowsInstaller.new
                  end
      if UI.interactive?
        unclean = []
        installer.installed.each { |unity| unclean << unity unless unity.clean_install? }
        unless unclean.empty?
          UI.important("u3d can optionally standardize the existing Unity3d installation names and locations. See the documentation for more information.")
          unclean.each { |unity| installer.sanitize_install(unity, dry_run: true) }
          if UI.confirm("#{unclean.count} Unity installation will be moved. Proceed??")
            unclean.each { |unity| installer.sanitize_install(unity) }
          end
        end
      end
      installer
    end

    def self.install_modules(files, version, installation_path: nil)
      installer = Installer.create
      files.each do |name, file, info|
        UI.verbose "Installing #{name}#{info['mandatory'] ? ' (mandatory package)' : ''}, with file #{file}"
        installer.install(file, version, installation_path: installation_path, info: info)
      end
    end
  end

  class MacInstaller
    def sanitize_install(unity, dry_run: false)
      source_path = File.expand_path('..', unity.path)
      parent = File.expand_path('..', source_path)
      new_path = File.join(parent, UNITY_DIR % unity.version)
      source_path = source_path.shellescape
      new_path = new_path.shellescape
      if dry_run
        UI.message "#{source_path} would move to #{new_path}"
      else
        UI.important "Moving #{source_path} to #{new_path}..."
        U3dCore::CommandExecutor.execute(command: "mv #{source_path} #{new_path}", admin: true)
        UI.success "Successfully moved #{source_path} to #{new_path}"
      end
    rescue => e
      UI.error "Unable to move #{source_path} to #{new_path}: #{e}"
    end

    def installed
      unless (`mdutil -s /` =~ /disabled/).nil?
        $stderr.puts 'Please enable Spotlight indexing for /Applications.'
        exit(1)
      end

      bundle_identifiers = ['com.unity3d.UnityEditor4.x', 'com.unity3d.UnityEditor5.x']

      mdfind_args = bundle_identifiers.map { |bi| "kMDItemCFBundleIdentifier == '#{bi}'" }.join(' || ')

      cmd = "mdfind \"#{mdfind_args}\" 2>/dev/null"
      UI.verbose cmd
      versions = `#{cmd}`.split("\n").map { |path| MacInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def install(file_path, version, installation_path: nil, _info: {})
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
      if unity.nil?
        UI.verbose "No Unity install for version #{version} was found"
        U3dCore::CommandExecutor.execute(command: command, admin: true)
      else
        begin
          path = File.expand_path('..', unity.path)
          temp_path = File.join(target_path, 'Applications', 'Unity')
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
  end

  class LinuxInstaller
    def sanitize_install(unity, dry_run: false)
      source_path = File.expand_path(unity.path)
      parent = File.expand_path('..', source_path)
      new_path = File.join(parent, UNITY_DIR_LINUX % unity.version)
      source_path = source_path.shellescape
      new_path = new_path.shellescape
      if dry_run
        UI.message "#{source_path} would move to #{new_path}"
      else
        UI.important "Moving #{source_path} to #{new_path}..."
        U3dCore::CommandExecutor.execute(command: "mv #{source_path} #{new_path}", admin: true)
        UI.success "Successfully moved #{source_path} to #{new_path}"
      end
    rescue => e
      UI.error "Unable to move #{source_path} to #{new_path}: #{e}"
    end

    def installed
      find = File.join(DEFAULT_LINUX_INSTALL, 'unity-editor-*')
      versions = Dir[find].map { |path| LinuxInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def install(file_path, version, installation_path: nil, _info: {})
      extension = File.extname(file_path)
      raise "Installation of #{extension} files is not supported on Linux" if extension != '.sh'
      path = installation_path || DEFAULT_LINUX_INSTALL
      install_sh(
        file_path,
        installation_path: path
      )
      # Forces sanitation for installation of 'weird' versions eg 5.6.1xf1Linux
      sanitize_install(installed.select { |u| u.version == version }.first)
    end

    def install_sh(file, installation_path: nil)
      cmd = file.shellescape
      if installation_path
        command = "cd \"#{installation_path}\"; #{cmd}"
        unless File.directory? installation_path
          command = "mkdir -p \"#{installation_path}\"; #{command}"
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
      source_path = "\"" + source_path + "\"" if source_path =~ / /
      new_path = "\"" + new_path + "\"" if new_path =~ / /

      if dry_run
        UI.message "#{source_path} would move to #{new_path}"
      else
        UI.important "Moving #{source_path} to #{new_path}..." unless dry_run
        U3dCore::CommandExecutor.execute(command: "move #{source_path} #{new_path}", admin: true)
        UI.success "Successfully moved #{source_path} to #{new_path}"
      end
    rescue => e
      UI.error "Unable to move #{source_path} to #{new_path}: #{e}"
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

  class UnityProject
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def exist?
      Dir.exist?("#{@path}/Assets") && Dir.exist?("#{@path}/ProjectSettings")
    end

    def editor_version
      require 'yaml'
      yaml = YAML.safe_load(File.read("#{@path}/ProjectSettings/ProjectVersion.txt"))
      version = yaml['m_EditorVersion']
      version.gsub!(/(\d+\.\d+\.\d+)(?:x)?(\w\d+)(?:Linux)?/, '\1\2') if Helper.linux?
      version
    end
  end
end
