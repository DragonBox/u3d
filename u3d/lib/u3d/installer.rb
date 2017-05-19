require 'u3d/utils'

# Mac specific only right now
module U3d
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
      fpath = "#{path}/Data/PlaybackEngines/LinuxStandaloneSupport/ivy.xml"
      raise "Couldn't find file #{fpath}" unless File.exist? fpath
      doc = REXML::Document.new(File.read(fpath))
      version = REXML::XPath.first(doc, 'ivy-module/info/@e:unityVersion').value
      if m = version.match(/^(.*)x(.*)Linux$/)
        version = "#{m[1]}#{m[2]}"
      end
      version
    end

    def default_log_file
      "#{ENV['HOME']}/.config/unity3d/Editor.log"
    end

    def exe_path
      "#{path}/Unity"
    end
  end

  class WindowsInstallation < Installation
    attr_reader :path

    def initialize(path: nil)
      @path = path
    end

    def version
      require 'rexml/document'
      fpath = "#{path}/Data/PlaybackEngines/windowsstandalonesupport/ivy.xml"
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
          UI.important "Log directory (#{log_dir}) does not exist"  unless Dir.exist? log_dir
          @logfile = File.expand_path('Editor.log', log_dir)
        rescue RuntimeError => ex
          UI.error "Unable to retrieve the editor logfile: #{ex}"
        end
      end
      @logfile
    end

    def exe_path
      File.expand_path('Unity.exe', @path)
    end
  end

  class Runner
    def run(installation, args)
      require 'fileutils'

      log_file = find_logFile_in_args(args)

      if log_file # we wouldn't want to do that for the default log file.
        File.delete(log_file) if File.exist?(log_file)
      else
        log_file = installation.default_log_file
      end

      FileUtils.touch(log_file)

      if Helper.windows?
        UI.important "Tailing unavailable for Windows at the moment, logs are at #{log_file}"
      else
        tail_pid = Process.spawn("tail -F #{log_file}")
      end

      begin
        args.unshift(installation.exe_path)
        if Helper.windows?
          args.map! do |a|
            if a =~ / / && !a.start_with?("\"")
              a = "\"#{a}\""
            end
            a
          end
        else
          args.map! { |a| a.shellescape }
        end
        U3dCore::CommandExecutor.execute(command: args)
      ensure
        Helper.backticks("kill #{tail_pid}") if tail_pid
      end
    end

    def find_logFile_in_args(args)
      find_arg_in_args('-logFile', args)
    end

    def find_projectpath_in_args(args)
      find_arg_in_args('-projectpath', args)
    end

    def find_arg_in_args(arg_to_find, args)
      raise 'Only arguments of type array supported right now' unless args.kind_of?(Array)
      args.each_with_index do |arg, index|
        return args[index + 1] if arg == arg_to_find && index < args.count - 1
      end
      nil
    end
  end

  class Installer
    DEFAULT_WINDOWS_INSTALL = 'C:/Program Files/Unity/'.freeze

    def self.create
      if Helper.mac?
        MacInstaller.new
      elsif Helper.linux?
        LinuxInstaller.new
      else
        WindowsInstaller.new
      end
    end

    def self.install_module(file_path, version, installation_path: nil, info: {})
      extension = File.extname(file_path)
      if extension == '.pkg'
        MacInstaller.install_pkg(
          file_path,
          target_path: installation_path
        )
      elsif extension == '.exe'
        path = installation_path || DEFAULT_WINDOWS_INSTALL
        path = path.chop + " #{version}/"
        Dir.mkdir path unless Dir.exist? path
        WindowsInstaller.install_exe(
          file_path,
          installation_path: path,
          info: info
        )
      elsif extension == '.sh'
        LinuxInstaller.install_sh(file_path)
      else
        raise "File type #{extension} not supported"
      end
    end
  end

  class MacInstaller
    def installed
      unless (`mdutil -s /` =~ /disabled/).nil?
        $stderr.puts 'Please enable Spotlight indexing for /Applications.'
        exit(1)
      end

      bundle_identifiers = ['com.unity3d.UnityEditor4.x', 'com.unity3d.UnityEditor5.x']

      mdfind_args = bundle_identifiers.map { |bi| "kMDItemCFBundleIdentifier == '#{bi}'" }.join(' || ')

      cmd = "mdfind \"#{mdfind_args}\" 2>/dev/null"
      versions = `#{cmd}`.split("\n").map { |path| MacInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def self.install_pkg(file_path, target_path: nil)
      target_path ||= '/'
      U3dCore::CommandExecutor.execute(command: "installer -pkg #{file_path.shellescape} -target #{target_path.shellescape}", admin: true)
    rescue => e
      UI.error "Failed to install pkg at #{file_path}: #{e}"
    end

    def self.install_pkg(file_path)
      begin
        U3dCore::CommandExecutor::execute(command: "installer -pkg #{file_path.shellescape} -target /", admin: true)
      rescue => e
        UI.error "Failed to install pkg at #{file_path}: #{e.to_s}"
      end
    end

    def self.install_pkg(file_path)
      begin
        U3dCore::CommandExecutor::execute(command: "installer -pkg #{file_path.shellescape} -target /", admin: true)
      rescue => e
        UI.error "Failed to install pkg at #{file_path}: #{e.to_s}"
      end
    end
  end

  class LinuxInstaller
    def installed
      # so many assumptions here...
      cmd = 'find /opt/ -maxdepth 3 -name Unity 2> /dev/null | xargs dirname'
      versions = `#{cmd}`.split("\n").map { |path| LinuxInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def self.install_sh(file)
      U3dCore::CommandExecutor.execute(command: file.shellescape, admin: true)
    rescue => e
      UI.error "Failed to install bash file at #{file_path}: #{e}"
    end
  end

  class WindowsInstaller
    def installed
      unity_paths = []

      require 'win32/registry'

      Win32::Registry::HKEY_LOCAL_MACHINE.open(
        'Software\Microsoft\Windows\CurrentVersion\Uninstall'
      ) do |reg|
        reg.each_key do |key|
          k = reg.open(key)
          begin
            _temp = k['DisplayName']
          rescue
            next
          else
            next unless /Unity/ =~ key
          end
          path = File.expand_path('..', k['UninstallString'])
          unity_paths << path
        end
      end

      versions = unity_paths.map { |path| WindowsInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def self.install_exe(file_path, installation_path: nil, info: {})
      installation_path ||= DEFAULT_WINDOWS_INSTALL
      installation_path = installation_path.split('/').join('\\')
      begin
        command = nil
        if info['cmd']
          command = info['cmd']
          command.sub!(/{FILENAME}/, file_path)
          command.sub!(/{INSTDIR}/, installation_path)
          command.sub!(/{DOCDIR}/, installation_path)
          command.sub!(/{MODULEDIR}/, installation_path)
          command.sub!(/\/D=/, '/S /D=') unless /\/S/ =~ command
        end
        command ||= file_path.to_s
        U3dCore::CommandExecutor.execute(command: command)
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
      yaml = YAML.load(File.read("#{@path}/ProjectSettings/ProjectVersion.txt"))
      yaml['m_EditorVersion']
    end
  end
end
