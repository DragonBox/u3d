module U3d
  class Commands
    class << self
      def list_installed
        puts Installer.create.installed.map {|v| "#{v.version}\t(#{v.path})" }.join("\n")
      end

      def run(config: {}, run_args: [])
        version = config[:unity_version]

        runner = Runner.new
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
