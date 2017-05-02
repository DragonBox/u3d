module U3dCore
  # Executes commands and takes care of error handling and more
  class CommandExecutor
    SUDO_CRED_PREFIX = 'u3d.sudo'
    class << self
      # Cross-platform way of finding an executable in the $PATH. Respects the $PATHEXT, which lists
      # valid file extensions for executables on Windows.
      #
      #    which('ruby') #=> /usr/bin/ruby
      #
      # Derived from http://stackoverflow.com/a/5471032/3005
      def which(cmd)
        # PATHEXT contains the list of file extensions that Windows considers executable, semicolon separated.
        # e.g. ".COM;.EXE;.BAT;.CMD"
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            cmd_path = File.expand_path("#{cmd}#{ext}", path)
            return cmd_path if File.executable?(cmd_path) && !File.directory?(cmd_path)
          end
        end

        return nil
      end

      # @param command [String] The command to be executed
      # @param print_all [Boolean] Do we want to print out the command output while running?
      # @param print_command [Boolean] Should we print the command that's being executed
      # @param error [Block] A block that's called if an error occurs
      # @param prefix [Array] An array containg a prefix + block which might get applied to the output
      # @param loading [String] A loading string that is shown before the first output
      # @param admin [Boolean] Do we need admin privilege for this command?
      # @return [String] All the output as string
      def execute(command: nil, print_all: false, print_command: true, error: nil, prefix: nil, loading: nil, admin: false)
        print_all = true if $verbose
        prefix ||= {}

        output = []
        command = command.join(" ") if command.kind_of?(Array)
        UI.command(command) if print_command

        if print_all and loading # this is only used to show the "Loading text"...
          UI.command_output(loading)
        end

        if admin
          UI.verbose 'Trying to gain admin privileges to execute the command'

          cm = CredentialsManager::AccountManager.new(
            user: ENV['USER'],
            prefix: SUDO_CRED_PREFIX
          )

          command = "sudo -k && echo #{cm.password} | sudo -S " + command
          UI.verbose 'Admin privileges granted for command execution'
        end

        begin
          status = U3dCore::Runner.run(command) do |stdin, stdout, pid|
            stdin.each do |l|
              line = l.strip # strip so that \n gets removed
              output << line

              next unless print_all

              # Prefix the current line with a string
              prefix.each do |element|
                line = element[:prefix] + line if element[:block] && element[:block].call(line)
              end

              UI.command_output(line)
            end
          end
          raise "Exit status: #{status}".red if status != 0 && status != nil
        rescue => ex
          # This could happen
          # * if the status is failed
          # * when the environment is wrong:
          # > invalid byte sequence in US-ASCII (ArgumentError)
          output << ex.to_s
          o = output.join("\n")
          puts o
          if error
            error.call(o, nil)
          else
            raise ex
          end
        end
        return output.join("\n")
      end

      def root_password_check
        cm = CredentialsManager::AccountManager.new(
          user: ENV['USER'],
          prefix: SUDO_CRED_PREFIX
        )
        tries = 0
        until tries > 10
          begin
            status = U3dCore::Runner.run("sudo -k && echo #{cm.password} | sudo -S /usr/bin/whoami") do |stdin, stdout, pid|
              result = stdin.read
              UI.command_output(result)
            end
          rescue => ex
            UI.error "Unable to check password validity (#{ex})"
            UI.error 'Password is assumed to be wrong'
          end
          if status != 0
            return false unless cm.invalid_credentials
          else
            return true
          end
          tries += 1
        end
        false
      end
    end
  end
end
