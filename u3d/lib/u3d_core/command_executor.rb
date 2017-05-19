require 'u3d_core/credentials'

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
        command = command.join(' ') if command.kind_of?(Array)
        UI.command(command) if print_command

        # this is only used to show the "Loading text"...
        UI.command_output(loading) if print_all && loading

        if admin
          cred = U3dCore::Credentials.new(user: ENV['USER'])
          if Helper.windows?
            raise "The command \'#{command}\' must be run in administrative shell" unless has_admin_privileges?
          else
            command = "sudo -k && echo #{cred.password} | sudo -S " + command
          end
          UI.verbose 'Admin privileges granted for command execution'
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
          raise "Exit status: #{status}".red if status != 0 && !status.nil?
        rescue => ex
          # This could happen
          # * if the status is failed
          # * when the environment is wrong:
          # > invalid byte sequence in US-ASCII (ArgumentError)
          output << ex.to_s
          o = output.join("\n")
          UI.verbose o
          raise ex unless error
          error.call(o, nil)
        end
        return output.join("\n")
      end

      def has_admin_privileges?
        if Helper.windows?
          begin
            result = system('reg query HKU\\S-1-5-19', :out => File::NULL, :err => File::NULL)
          rescue
            return false
          end
        else
          credentials = U3dCore::Credentials.new(user: ENV['USER'])
          begin
            result = system("sudo -k && echo #{credentials.password} | sudo -S /usr/bin/whoami")
          rescue
            return false
          end
        end
        # returns false if result is nil (command execution fail)
        return (result ? true : false)
      end
    end
  end
end
