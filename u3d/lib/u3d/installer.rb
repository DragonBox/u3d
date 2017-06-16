require 'u3d/utils'

# Mac specific only right now
module U3d

  DEFAULT_LINUX_INSTALL = '/opt/'.freeze
  DEFAULT_MAC_INSTALL = '/'.freeze
  DEFAULT_WINDOWS_INSTALL = 'C:/Program Files/'.freeze

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
      fpath = File.expand_path('../PlaybackEngines', path)
      raise "Unity installation does not seem correct. Couldn't locate PlaybackEngines." unless Dir.exist? fpath
      Dir.entries(fpath).select { |e| File.directory?(File.join(fpath, e)) && !(e == '.' || e == '..') }
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

    def packages
      false
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
          UI.important "Log directory (#{log_dir}) does not exist"  unless Dir.exist? log_dir
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
      fpath = "#{path}/Editor/Data/PlaybackEngines/"
      raise "Unity installation does not seem correct. Couldn't locate PlaybackEngines." unless Dir.exist? fpath
      Dir.entries(fpath).select { |e| File.directory?(File.join(fpath, e)) && !(e == '.' || e == '..') }
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

      tail_thread = Thread.new do
        File.open(log_file, 'r') do |f|
          LogAnalyzer.pipe(f, sleep_time: 0.5)
        end
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
        Thread.kill(tail_thread) if tail_thread
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
        path = installation_path || DEFAULT_MAC_INSTALL
        MacInstaller.install_pkg(
          file_path,
          target_path: path
        )
      elsif extension == '.exe'
        path = installation_path || File.expand_path("Unity_#{version}", DEFAULT_WINDOWS_INSTALL)
        WindowsInstaller.install_exe(
          file_path,
          installation_path: path,
          info: info
        )
      elsif extension == '.sh'
        path = installation_path || File.expand_path("Unity_#{version}", DEFAULT_LINUX_INSTALL)
        LinuxInstaller.install_sh(
          file_path,
          installation_path: path
        )
      else
        raise "File type #{extension} not yet supported"
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
      target_path ||= DEFAULT_MAC_INSTALL
      U3dCore::CommandExecutor.execute(command: "installer -pkg #{file_path.shellescape} -target #{target_path.shellescape}", admin: true)
    rescue => e
      UI.error "Failed to install pkg at #{file_path}: #{e.to_s}"
    else
      UI.success "Successfully installed package from #{file_path}"
    end
  end

  class LinuxInstaller
    def installed
      find = File.join(DEFAULT_LINUX_INSTALL, 'Unity*')
      versions = Dir[find].map { |path| WindowsInstallation.new(path: path) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def self.install_sh(file, installation_path: nil)
      cmd = file.shellescape
      if installation_path
        Utils.ensure_dir(installation_path)
        Dir.chdir(installation_path) do
          U3dCore::CommandExecutor.execute(command: cmd, admin: true)
        end
      else
        U3dCore::CommandExecutor.execute(command: cmd, admin: true)
      end
    rescue => e
      UI.error "Failed to install bash file at #{file_path}: #{e}"
    else
      UI.success 'Installation successful'
    end
  end

  class WindowsInstaller
    def installed
      find = File.join(DEFAULT_WINDOWS_INSTALL, 'Unity*', 'Editor', 'Uninstall.exe')
      versions = Dir[find].map { |path| WindowsInstallation.new(path: File.expand_path('../..', path)) }

      # sorting should take into account stable/patch etc
      versions.sort! { |x, y| x.version <=> y.version }
    end

    def self.install_exe(file_path, installation_path: nil, info: {})
      installation_path ||= DEFAULT_WINDOWS_INSTALL
      final_path = installation_path.gsub('/', '\\')
      Utils.ensure_dir(final_path)
      begin
        command = nil
        if info['cmd']
          command = info['cmd']
          command.sub!(/{FILENAME}/, file_path)
          command.sub!(/{INSTDIR}/, final_path)
          command.sub!(/{DOCDIR}/, final_path)
          command.sub!(/{MODULEDIR}/, final_path)
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
