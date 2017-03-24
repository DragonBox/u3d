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
      program :help, 'Author', 'Jerome Lacoste <jerome@wewanttoknow.com>'
      program :help_formatter, :compact

      global_option('--verbose') { $verbose = true }

      command :run do |c|
        # Intended for backward compatibilty purposes for run command
        # Meant to fetch options after '--' unknown by CommandsGenerator
        run_args = extract_run_args

        c.syntax = 'u3d run [-u | --unity_version <version>] [ -- <run_args>]'
        c.description = 'Run unity'
        U3dCore::CommanderGenerator.new.generate(U3d::Options.available_run_options)
        c.action do |args, options|
          config = convert_options(options)
          Commands.run(config: config, run_args: run_args)
        end
      end

      command :installed do |c|
        c.syntax = 'u3d installed'
        c.description = 'List installed version of Unity3d'
        c.action do |_args, _options|
          Commands.list_installed
        end
      end

      command :available do |c|
        c.syntax = 'u3d available'
        c.option '-u', '--unity_version', String, 'Checks if specified version is available'
        c.option '-p', '--packages', 'Lists available packages as well'
        c.description = 'List download-ready versions of Unity3d'
        c.action do |_args, options|
          options.default packages: false
          config = convert_options(options)
          Commands.list_available(options: config)
        end
      end

      command :download do |c|
        c.syntax = 'u3d download <version> [ [-p | --packages <package> ...] | [-a | --all] ] [-n | --no_install]'
        c.description = 'Download Unity3D packages'
        c.option '-p', '--packages PACKAGES', Array, 'Specifies which packages to download. Overriden by --all'
        c.option '-a', '--all', 'Download all available packages'
        c.option '-n', '--no_install', 'No installation after download success'
        c.action do |args, options|
          options.default all: false
          options.default no_install: false
          config = convert_options(options)
          Commands.download(args: args, options: config)
        end
      end

      command :local_install do |c|
        c.syntax = 'u3d local_install <pkg>'
        c.description = 'Install downloaded version of unity'
        c.action do |args, _options|
          Commands.local_install(args: args)
        end
      end

      default_command :run

      run!
    end
  end
end
