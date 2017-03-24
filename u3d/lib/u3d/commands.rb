require 'u3d/unity_versions'
require 'u3d/downloader'
require 'u3d/installer'
require 'u3d/cache'
require 'u3d/utils'

module U3d
  # API for U3d, redirecting calls to class they concern
  class Commands
    class << self
      def list_installed
        puts Installer.create.installed.map { |v| "#{v.version}\t(#{v.path})" }.join("\n")
      end

      def list_available(options: {})
        cache = Cache.new
        versions = {}

        ver = options[:unity_version]

        return UI.error "Version #{ver} is not in cache" if ver && cache['versions'][ver].nil?

        if ver
          versions = { ver => cache['versions'][ver] }
        else
          versions = cache['versions']
        end
        versions.each do |k, v|
          UI.message "Version #{k}: " + v.to_s.cyan.underline
          if options[:packages]
            inif = nil
            begin
              inif = U3d::INIparser.load_ini(k, versions)
            rescue => e
              UI.error "Could not load packages for this version (#{e})"
            else
              UI.message 'Packages:'
              inif.keys.each { |pack| UI.message " - #{pack}"}
            end
          end
        end
      end

      def download(args: [], options: {})
        version = args[0]
        UI.user_error!('Please specify a Unity version to download') unless version
        options[:packages] ||= ['Unity']
        cache = Cache.new
        files = []
        if options[:all]
          files = Downloader.download_all(version, cache['versions'])
        else
          packages = options[:packages]
          packages.each do |package|
            result = Downloader.download_specific(package, version, cache['versions'])
            files << result unless result.nil?
          end
        end
        return if options[:no_install]
        files.each do |f|
          Installer.install_module(f)
        end
      end

      def local_install(args: [])
        UI.user_error!('No file passed') if args.empty?
        UI.user_error!("#{args[0]} is not a file") unless File.file?(args[0])
        Installer.install_module(args[0])
      end

      def run(config: {}, run_args: [])
        version = config[:unity_version]

        runner = Runner.new
        pp = runner.find_projectpath_in_args(run_args)
        pp = Dir.pwd unless pp
        up = UnityProject.new(pp)

        if !version # fall back in project default if we are on a Unity project
          version = up.editor_version if up.exist?
          if !version
            UI.user_error!('Not sure which version of Unity to run. Are you in a project?')
          end
        end

        run_args = ['-projectpath', up.path] if run_args.empty? && up.exist?

        # we could
        # * support matching 5.3.6p3 if passed 5.3.6
        unity = Installer.create.installed.find { |u| u.version == version }
        UI.user_error! "Unity version '#{version}' not found" unless unity
        runner.run(unity, run_args)
      end
    end
  end
end
