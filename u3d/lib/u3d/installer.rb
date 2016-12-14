# Mac specific only right now
module U3d
  class Installation
    def self.create(path: nil)
      if Helper.mac?
        MacInstallation.new path
      elsif Helper.linux?
        LinuxInstallation.new path
      else
        raise "Support for Windows platform not yet handled"
      end
    end
  end

  class MacInstallation < Installation
    attr_reader :path

    require 'plist'

    def initialize(path: nil)
      @path=path
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
      @plist ||= Plist::parse_xml("#{@path}/Contents/Info.plist")
    end
  end

  class LinuxInstallation < Installation
    attr_reader :path

    def initialize(path: nil)
      @path=path
    end

    def version
      # I don't find an easy way to extract the version on Linux
      require 'rexml/document'
      fpath = "#{path}/Data/PlaybackEngines/LinuxStandaloneSupport/ivy.xml"
      raise "Couldn't find file #{fpath}" unless File.exist? fpath
      doc = REXML::Document.new(File.read(fpath))
      version=REXML::XPath.first(doc, 'ivy-module/info/@e:unityVersion').value
      if m=version.match(/^(.*)x(.*)Linux$/)
        version="#{m[1]}#{m[2]}"
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

  class Runner
    def run(installation, args)
      require 'fileutils'

      log_file = find_logFile_in_args(args)

      if (log_file) # we wouldn't want to do that for the default log file.
        File.delete(log_file) if File.exist?(log_file)
      else
        log_file = installation.default_log_file
      end

      FileUtils.touch(log_file)

      tail_pid = Process.spawn("tail -F #{log_file}")

      begin
        args.unshift(installation.exe_path)
        args.map!{|a| a.shellescape }
        U3dCore::CommandExecutor::execute(command: args)
      ensure
        Helper.backticks("kill #{tail_pid}")
      end
    end

    def find_logFile_in_args(args)
      find_arg_in_args("-logFile", args)
    end

    def find_projectpath_in_args(args)
      find_arg_in_args("-projectpath", args)
    end

    def find_arg_in_args(arg_to_find, args)
      raise "Only arguments of type array supported right now" unless args.kind_of?(Array)
      args.each_with_index { |arg, index|
        if arg == arg_to_find and index < args.count - 1
          return args[index+1]
        end
      }
      nil
    end

  end

  class Installer
    def self.create()
      if Helper.mac?
        MacInstaller.new
      elsif Helper.linux?
        LinuxInstaller.new
      else
        raise "Support for Windows platform not yet handled"
      end
    end
  end

  class MacInstaller
    def installed
      unless (`mdutil -s /` =~ /disabled/).nil?
        $stderr.puts 'Please enable Spotlight indexing for /Applications.'
        exit(1)
      end

      bundle_identifiers=['com.unity3d.UnityEditor4.x', 'com.unity3d.UnityEditor5.x']

      mdfind_args = bundle_identifiers.map{|bi| "kMDItemCFBundleIdentifier == '#{bi}'"}.join(" || ")

      command="mdfind \"#{mdfind_args}\" 2>/dev/null" 
      versions=`#{command}`.split("\n").map {|path| MacInstallation.new(path: path) }

      versions.sort!{ |x,y| x.version <=> y.version } # sorting should take into account stable/patch etc
    end
  end

  class LinuxInstaller
    def installed
      # so many assumptions here...
      command="find /opt/ -maxdepth 3 -name Unity 2> /dev/null | xargs dirname"
      versions=`#{command}`.split("\n").map {|path| LinuxInstallation.new(path: path) }

      versions.sort!{ |x,y| x.version <=> y.version } # sorting should take into account stable/patch etc
    end
  end

  class UnityProject
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def exist?
      Dir.exist?("#{@path}/Assets") and Dir.exist?("#{@path}/ProjectSettings")
    end

    def editor_version
      require 'yaml'
      yaml=YAML.load(File.read("#{@path}/ProjectSettings/ProjectVersion.txt"))
      yaml['m_EditorVersion']
    end
  end

  class Commands
    class << self
      def list_installed
        puts Installer.create.installed.map {|v| "#{v.version}\t(#{v.path})" }.join("\n")
      end
      
      def run(config: {}, run_args: [])
        version = config[:unity_version]

        runner = Runner.new

        pp = runner.find_projectpath_in_args(run_args)
        pp = Dir.pwd unless pp
        up = UnityProject.new(pp)

        if (!version) # fall back in project default if we are on a Unity project
          version = up.editor_version if up.exist?
          if (!version)
            UI.user_error!("Not sure which version of Unity to run. Are you in a project?")
          end
        end

        # when no argument passed, just start Unity (open the project)
        run_args = ["-projectpath", up.path] if run_args.empty? and up.exist?

        # we could
        # * support matching 5.3.6p3 if passed 5.3.6
        unity = Installer.create.installed.find{|u| u.version == version}
        UI.user_error! "Unity version '#{version}' not found" unless unity
        runner.run(unity, run_args)
      end
    end
  end
end