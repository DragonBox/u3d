require 'commander'
require 'u3d_core'
require 'u3d/commands'

HighLine.track_eof = false

module U3d
  # CLI using commander gem for u3d
  class CommandsGenerator
    include Commander::Methods
    UI = U3dCore::UI

    def self.start
      # FastlaneCore::UpdateChecker.start_looking_for_update("gym")
      new.run
    ensure
      # FastlaneCore::UpdateChecker.show_update_status("gym", Gym::VERSION)
    end

    def extract_run_args(args = ARGV)
      both_args = [[], []]
      idx = 0
      args.each do |arg|
        if arg == '--'
          idx = 1
          next
        end
        both_args[idx] << arg
      end
      args.replace both_args[0]
      both_args[1]
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :version, U3d::VERSION
      program :description, U3d::DESCRIPTION
      program :help, 'Authors', 'Jerome Lacoste <jerome@wewanttoknow.com>, Paul Niezborala <p.niezborala@wewanttoknow.com>'
      program :help, 'A word on Unity versions', U3d::UNITY_VERSIONS_NOTE
      program :help_formatter, :compact

      global_option('--verbose') { $verbose = true }

      command :run do |c|
        # Intended for backward compatibilty purposes for run command
        # Meant to fetch options after '--' unknown by CommandsGenerator
        run_args = extract_run_args

        c.syntax = 'u3d run [-u | --unity_version <version>] [ -- <run_args>]'
        c.description = 'Run unity'
        U3dCore::CommanderGenerator.new.generate(U3d::Options.available_run_options)
        c.action do |_args, options|
          config = convert_options(options)
          Commands.run(options: config, run_args: run_args)
        end
      end

      command :list do |c|
        c.syntax = 'u3d list [-p | --packages]'
        c.option '-p', '--packages', 'Lists installed packages as well'
        c.example 'List currently installed Unity3d versions, as well as installed packages', 'u3d list -p'
        c.description = 'List installed version of Unity3d'
        c.action do |_args, options|
          Commands.list_installed(options: convert_options(options))
        end
      end

      command :available do |c|
        c.syntax = 'u3d available [-o | --operating_system <OS>] [-u | --unity_version <version>] [-p | --packages]'
        c.option '-o', '--operating_system STRING', String, 'Checks for availability on specific OS'
        c.option '-u', '--unity_version STRING', String, 'Checks if specified version is available'
        c.option '-p', '--packages', 'Lists available packages as well'
        c.example 'List packages available for Unity version 5.6.0f3', 'u3d available -u 5.6.0f3 -p'
        c.description = 'List download-ready versions of Unity3d'
        c.action do |_args, options|
          options.default packages: false
          Commands.list_available(options: convert_options(options))
        end
      end

      command :install do |c|
        c.syntax = 'u3d install <version> [ [-p | --packages <package> ...] | [-a | --all] ] [ [-n | --no_install] [-i | --installation_path <path>] ]'
        c.description = 'Download and install Unity3D packages'
        c.option '-p', '--packages PACKAGES', Array, 'Specifies which packages to download. Overriden by --all'
        c.option '-i', '--installation_path PATH', String, 'Specifies where package(s) will be installed. Overriden by --no_install'
        c.option '-a', '--all', 'Download all available packages'
        c.option '-n', '--no_install', 'No installation after download success'
        c.example 'Download and install Unity, its Documentation and the Android build support and install them for version 5.1.2f1', 'u3d install 5.1.2f1 -p Unity,Documentation,Android'
        c.action do |args, options|
          options.default all: false
          options.default no_install: false
          config = convert_options(options)
          Commands.download(args: args, options: convert_options(options))
        end
      end

      command :local_install do |c|
        c.syntax = 'u3d local_install <version> [ [-p | --packages <package> ...] | [-a | --all] ] [-i | --installation_path <path>]'
        c.description = 'Install downloaded version of unity'
        c.option '-p', '--packages PACKAGES', Array, 'Specifies which packages to install. Overriden by --all'
        c.option '-i', '--installation_path PATH', String, 'Specifies where package(s) will be installed.'
        c.option '-a', '--all', 'Install all downloaded packages'
        c.action do |args, options|
          config = convert_options(options)
          Commands.local_install(args: args, options: convert_options(options))
        end
      end

      command :login do |c|
        c.syntax = 'u3d login [-u | --user <username>]'
        c.description = 'Stores credentials for future use'
        c.option '-u', '--user USER', String, 'Specifies wich user will be logged in'
        c.action do |_args, options|
          config = convert_options(options)
          Commands.login(options: config)
        end
      end

      command :analyze_log do |c|
        c.syntax = 'u3d analyze_log <logfile>'
        c.description = 'Run a saved logfile through the log processing'
        c.action do |args, _options|
          Commands.local_analyze(args: args)
        end
      end

      default_command :run

      run!
    end
  end
end
