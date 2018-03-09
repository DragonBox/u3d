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
  # rubocop:disable ClassLength
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

      global_option('--verbose', 'Run in verbose mode') { U3dCore::Globals.verbose = true }

      command :run do |c|
        # Intended for backward compatibilty purposes for run command
        # Meant to fetch options after '--' unknown by CommandsGenerator
        run_args = extract_run_args

        c.syntax = 'u3d run [-u | --unity_version <version>] [-r | --raw_logs] [ -- <run_args>]'
        c.summary = 'Run Unity, and parse its output through u3d\'s log prettifier'
        c.description =  %(
#{c.summary}
The default prettifier rules file is packaged with u3d (#{U3d::LogAnalyzer::RULES_PATH}).
You may which to pass your own using the environment variable U3D_RULES_PATH.

E.g. U3D_RULES_PATH=my_rules.json u3d -- ...

Fore more information about how the rules work, see https://github.com/DragonBox/u3d/blob/master/LOG_RULES.md
        )
        c.option '-u', '--unity_version STRING', String, 'Version of Unity to run with. If not specified, it runs with the version of the project (either specified as -projectpath or current)'
        c.option '-r', '--raw_logs', 'Raw Unity output, not filtered by u3d\'s log prettifier'
        c.action do |args, options|
          UI.user_error! "Run doesn't take arguments. Did you forget '--' or did you mistake your command? (#{args})" if args.count > 0
          U3dCore::Globals.log_timestamps = true
          Commands.run(options: convert_options(options), run_args: run_args)
        end
      end

      command :list do |c|
        c.syntax = 'u3d list [-p | --packages]'
        c.option '-p', '--packages', 'Lists installed packages as well'
        c.example 'List currently installed Unity versions, as well as installed packages', 'u3d list -p'
        c.summary = 'List installed versions of Unity'
        c.action do |_args, options|
          Commands.list_installed(options: convert_options(options))
        end
      end

      command :available do |c|
        oses = U3dCore::Helper.operating_systems
        c.syntax = 'u3d available [-r | --release_level <level>] [-o | --operating_system <OS>] [-u | --unity_version <version>] [-p | --packages] [-f | --force]'
        levels = Commands.release_levels
        c.option '-f', '--force', 'Force refresh list of available versions'
        c.option '-r', '--release_level STRING', String, "Checks for availability on specific release level [#{levels.join(', ')}]"
        c.option '-o', '--operating_system STRING', String, "Checks for availability on specific OS [#{oses.join(', ')}]"
        c.option '-u', '--unity_version STRING', String, 'Checks if specified version is available. Can be a regular expression'
        c.option '-p', '--packages', 'Lists available packages as well'
        c.example 'List all versions available, forcing a refresh of the available packages from Unity servers', 'u3d available -f'
        c.example 'List stable versions available', 'u3d available -r stable -p'
        c.example 'List all versions available for Linux platform', 'u3d available -o linux'
        c.example 'List packages available for Unity version 5.6.0f3', 'u3d available -u 5.6.0f3 -p'
        c.example 'List packages available for Unity version containing the 5.6 string', 'u3d available -u \'5.6\' -p'
        c.summary = 'List download-ready versions of Unity'
        c.action do |_args, options|
          options.default packages: false
          Commands.list_available(options: convert_options(options))
        end
      end

      command :install do |c|
        oses = U3dCore::Helper.operating_systems
        c.syntax = 'u3d install [<version>] [ [-p | --packages <package1>,<package2> ...] | [-o | --operating_system <OS>] [-a | --all] ] [--[no-]download] [ [--[no-]install] [-i | --installation_path <path>] ]'
        c.summary = 'Download (and/or) install Unity editor packages'
        c.description = %(
#{c.summary}
This command allows you to either:
* download and install packages
* download packages but not install them
* install already downloaded packages
Already installed packages are skipped if asked to be installed again (except for the 'Example' package).

The default download path is $HOME/Downloads/Unity_Packages/, but you may change that by specifying the environment variable U3D_DOWNLOAD_PATH.

E.g. U3D_DOWNLOAD_PATH=/some/path/you/want u3d install ...
        )
        c.option '--[no-]download', 'Perform or not downloading before installation. Downloads by default'
        c.option '--[no-]install', 'Perform or not installation after downloading. Installs by default'
        c.option '-p', '--packages PACKAGES', Array, 'Specifies which packages to download/install. Overriden by --all'
        c.option '-o', '--operating_system STRING', String, "Downloads packages for specific OS [#{oses.join(', ')}]. Requires the --no-install option."
        c.option '-a', '--all', 'Download all available packages. Overrides -p'
        c.option '-i', '--installation_path PATH', String, 'Specifies where package(s) will be downloaded/installed. Conflicts with --no-install'
        c.option '-k', '--keychain', 'Gain privileges right through the keychain. [OSX only]'
        c.example 'Download and install Unity, its Documentation and the Android build support and install them for version 5.1.2f1', 'u3d install 5.1.2f1 -p Unity,Documentation,Android'
        c.example 'Download but do not install all Unity version 2018.1.0b2 packages for platform Windows (while e.g. on Mac)', 'u3d install 2018.1.0b2 -o win -a --no-install'
        c.example "The 'version' argument can be a specific version number, such as 5.6.1f1, or an alias in [#{Commands.release_letter_mapping.keys.join(', ')}]. If not specified, u3d will download the unity version for the current project", 'u3d install latest'
        c.example "The admin password can be passed through the U3D_PASSWORD environment variable.", 'U3D_PASSWORD=mysecret u3d install a_version'
        c.example "On Mac, the admin password can be fetched from (and stored into) the keychain.", 'u3d install -k a_version'
        c.action do |args, options|
          options.default all: false
          options.default install: true
          options.default download: true
          Commands.install(args: args, options: convert_options(options))
        end
      end

      command :uninstall do |c|
        c.syntax = 'u3d uninstall [<version>]'
        c.summary = 'Uninstall the specified Unity version'
        c.option '-k', '--keychain', 'Gain privileges right through the keychain. [OSX only]'
        c.example 'Uninstall Unity version 5.2.1f1', 'u3d uninstall 5.1.2f1'
        c.action do |args, options|
          Commands.uninstall(args: args, options: convert_options(options))
        end
      end

      command :dependencies do |c|
        c.syntax = 'u3d dependencies'
        c.summary = 'Install Unity dependencies [Linux only]'
        c.description = %(
#{c.summary}
Regarding the package manager: if dpkg is installed, u3d uses apt-get else if rpm is installed yum is used. If none of them is insalled, fails.
Regarding the dependencies themselves: only dependencies for the editor are installed. WebGL, Android and Tizen require others that you will have to install manually.
More on that: https://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/
                  )
        c.action do |_args, _options|
          Commands.install_dependencies
        end
      end

      command :credentials do |c|
        c.syntax = "u3d credentials <#{Commands.credentials_actions.join(' | ')}>"
        c.summary = 'Manage keychain credentials so u3d remembers them [OSX only]'
        c.action do |args, _options|
          Commands.credentials(args: args)
        end
      end

      command :prettify do |c|
        c.syntax = 'u3d prettify <logfile>'
        c.summary = 'Prettify a saved Unity logfile'
        c.description = %(
          #{c.summary}
          The default prettifier rules file is packaged with u3d (#{U3d::LogAnalyzer::RULES_PATH}).
          You may which to pass your own using the environment variable U3D_RULES_PATH.
          E.g. U3D_RULES_PATH=my_rules.json u3d prettify ...
          Fore more information about how the rules work, see https://github.com/DragonBox/u3d/blob/master/LOG_RULES.md
                  )
        c.action do |args, _options|
          Commands.local_analyze(args: args)
        end
      end

      default_command :run

      run!
    end
  end
  # rubocop:enable ClassLength
end
