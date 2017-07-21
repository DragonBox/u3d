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
      new.run
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

      global_option('--verbose') { U3dCore::Globals.verbose = true }

      command :run do |c|
        # Intended for backward compatibilty purposes for run command
        # Meant to fetch options after '--' unknown by CommandsGenerator
        run_args = extract_run_args

        c.syntax = 'u3d run [-u | --unity_version <version>] [-r | --raw_logs] [ -- <run_args>]'
        c.description = 'Run unity, and parses its output through u3d\'s log prettifier'
        c.option '-u', '--unity_version STRING', String, 'Version of Unity to run with'
        c.option '-r', '--raw_logs', 'Raw Unity output, not filtered by u3d\'s log prettifier'
        c.action do |_args, options|
          U3dCore::Globals.log_timestamps = true
          Commands.run(options: convert_options(options), run_args: run_args)
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
        oses = U3dCore::Helper.operating_systems
        c.syntax = 'u3d available [-r | --release_level <level>] [-o | --operating_system <OS>] [-u | --unity_version <version>] [-p | --packages] [-f | --force]'
        levels = Commands::release_levels
        c.option '-r', '--release_level STRING', String, "Checks for availability on specific release level [#{levels.join(',')}]"
        c.option '-o', '--operating_system STRING', String, "Checks for availability on specific OS [#{oses.join(', ')}]"
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
        c.description = "Download (and install) Unity3D packages."
        c.option '-p', '--packages PACKAGES', Array, 'Specifies which packages to download. Overriden by --all'
        c.option '-i', '--installation_path PATH', String, 'Specifies where package(s) will be installed. Overriden by --no_install'
        c.option '-a', '--all', 'Download all available packages'
        c.option '-n', '--no_install', 'No installation after download success'
        c.option '-k', '--keychain', 'Gain privileges right through the keychain. [OSX only]'
        c.example 'Download and install Unity, its Documentation and the Android build support and install them for version 5.1.2f1', 'u3d install 5.1.2f1 -p Unity,Documentation,Android'
        c.example "The 'version' argument can be a specific version number, such as 5.6.1f1, or an alias in [#{Commands::release_letter_mapping.keys.join(',')}]", 'u3d install latest'
        c.action do |args, options|
          options.default all: false
          options.default no_install: false
          Commands.download(args: args, options: convert_options(options))
        end
      end

      command :local_install do |c|
        c.syntax = 'u3d local_install <version> [ [-p | --packages <package> ...] | [-a | --all] ] [-i | --installation_path <path>]'
        c.description = 'Install downloaded version of unity'
        c.option '-p', '--packages PACKAGES', Array, 'Specifies which packages to install. Overriden by --all'
        c.option '-i', '--installation_path PATH', String, 'Specifies where package(s) will be installed.'
        c.option '-a', '--all', 'Install all downloaded packages'
        c.option '-k', '--keychain', 'Gain privileges right through the keychain. [OSX only]'
        c.action do |args, options|
          Commands.local_install(args: args, options: convert_options(options))
        end
      end

      command :credentials do |c|
        c.syntax = 'u3d credentials <add | remove> [-u | --user <username>]'
        c.description = 'Manages credentials so u3d remembers them'
        c.option '-u', '--user USER', String, 'Specifies wich user will used'
        c.action do |args, options|
          Commands.credentials(args: args, options: convert_options(options))
        end
      end

      command :prettify do |c|
        c.syntax = 'u3d prettify <logfile>'
        c.description = 'Run a saved logfile through the log prettifying'
        c.action do |args, _options|
          Commands.local_analyze(args: args)
        end
      end

      default_command :run

      run!
    end
  end
end
