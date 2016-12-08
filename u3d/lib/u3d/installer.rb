require 'plist'

# Mac specific only right now
module U3d
  class Installation
    attr_reader :path, :version

    def initialize(path: nil)
      @path=path
    end

    def version
      plist['CFBundleVersion']
    end

    def exe_path
      "#{path}/Contents/MacOS/Unity"
    end

    def plist
      @plist ||= Plist::parse_xml("#{@path}/Contents/Info.plist")
    end
  end

  class Runner
    def run(installation, args)
      require 'fileutils'

      log_file = find_logFile_in_args(args)

      if (log_file && File.exist?(log_file))
        File.delete(log_file)
      end
      FileUtils.touch(log_file)

      tail_pid = Process.spawn("tail -F #{log_file}")

      begin
        args.unshift(installation.exe_path)
        U3dCore::CommandExecutor::execute(command: args)
      ensure
        puts "kill #{tail_pid}"
        `kill #{tail_pid}`
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
    def installed
      unless (`mdutil -s /` =~ /disabled/).nil?
        $stderr.puts 'Please enable Spotlight indexing for /Applications.'
        exit(1)
      end

      bundle_identifiers=['com.unity3d.UnityEditor4.x', 'com.unity3d.UnityEditor5.x']

      mdfind_args = bundle_identifiers.map{|bi| "kMDItemCFBundleIdentifier == '#{bi}'"}.join(" || ")

      command="mdfind \"#{mdfind_args}\" 2>/dev/null" 
      versions=`#{command}`.split("\n").map {|path| Installation.new(path: path) }

      versions.sort!{ |x,y| x.version <=> y.version } # sorting should take into account stable/patch etc
    end
  end

  class UnityProject
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
        puts Installer.new.installed.map {|v| "#{v.version}\t(#{v.path})" }.join("\n")
      end
      
      def run(config: {}, run_args: "")
        version = config[:unity_version]

        runner = Runner.new

        if (!version) # fall back in project default if we are on a Unity project
          pp = runner.find_projectpath_in_args(run_args)
          pp = "." unless pp
          up = UnityProject.new(pp)
          version = up.editor_version if up.exist?
          if (!version)
            UI.user_error!("Not sure which version of Unity to run")
          end
        end


        # we could
        # * support matching 5.3.6p3 if passed 5.3.6
        unity = Installer.new.installed.find{|u| u.version == version}
        UI.user_error! "Unity version '#{version}' not found" unless unity
        runner.run(unity, run_args)
      end
    end
  end
end