# frozen_string_literal: true

## --- BEGIN LICENSE BLOCK ---
# Original work Copyright (c) 2015-present the fastlane authors
# Modified work Copyright 2016-present WeWantToKnow AS
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

require 'u3d_core/credentials'

module U3dCore
  # Executes commands and takes care of error handling and more
  class CommandExecutor
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
      # @param admin [Boolean] Do we need admin privilege for this command?
      # @return [String] All the output as string
      # @deprecated
      def execute(command: nil, print_all: false, print_command: true, error: nil, prefix: nil, admin: false)
        print_all = true if U3dCore::Globals.verbose?
        prefix ||= {}

        output_callback = nil
        if print_all
          output_callback = proc do |line|
            # Prefix the current line with a string
            prefix.each do |element|
              line = element[:prefix] + line if element[:block]&.call(line)
            end
            UI.command_output(line)
          end
        end

        execute_command(command: command, output_callback: output_callback, print_command: print_command, error_callback: error, admin: admin)
      end

      # @param command [String] The command to be executed
      # @param output_callback [Block] the command to pass to print output
      # @param print_command [Boolean] Should we print the command that's being executed
      # @param error_callback [Block] A block that's called if an error occurs
      # @param admin [Boolean] Do we need admin privilege for this command?
      # @return [String] All the output as string
      def execute_command(command: nil, output_callback: nil, print_command: true, error_callback: nil, admin: false)
        command = command.join(' ') if command.is_a?(Array)
        UI.command(command) if print_command

        command = grant_admin_privileges(command) if admin

        execute_command_low(command: command, output_callback: output_callback, error_callback: error_callback)
      end

      def execute_command_low(command: nil, output_callback: nil, error_callback: nil)
        output = []
        begin
          status = U3dCore::Runner.run(command) do |stdin, _stdout, _pid|
            stdin.each do |l|
              line = l.strip # strip so that \n gets removed
              output << line

              output_callback&.call(l)
            end
          end
          raise "Exit status: #{status}".red if !status.nil? && status.nonzero?
        rescue StandardError => e
          # This could happen
          # * if the status is failed
          # * when the environment is wrong:
          # > invalid byte sequence in US-ASCII (ArgumentError)
          output << e.to_s
          o = output.join("\n")
          UI.verbose o
          raise e unless error_callback

          error_callback.call(o, nil)
        end
        return output.join("\n")
      end

      # rubocop:disable Naming/PredicateName
      def has_admin_privileges?(retry_count: 2)
        # rubocop:enable Naming/PredicateName
        if Helper.windows?
          begin
            result = system_no_output('reg query HKU\\S-1-5-19')
          rescue StandardError
            result = false
          end
        else
          env_username = ENV['USER']
          if env_username == "root"
            result = true
          else
            credentials = U3dCore::Credentials.new(user: env_username)
            begin
              result = system_no_output("sudo -k && echo #{credentials.password.shellescape} | sudo -S /usr/bin/whoami")
            rescue StandardError
              result = false
            end
            credentials.forget_credentials unless result # FIXME: why?
          end
        end
        # returns false if result is nil (command execution fail)
        result = result ? true : false
        result = has_admin_privileges?(retry_count: retry_count - 1) unless retry_count <= 0 || result
        result
      end

      def grant_admin_privileges(command)
        if Helper.windows?
          raise CredentialsError, "The command \'#{command}\' must be run in administrative shell" unless has_admin_privileges?
        else
          env_username = ENV['USER']
          unless env_username == "root"
            cred = U3dCore::Credentials.new(user: env_username)
            raise CredentialsError, "The command \'#{command}\' must be run with admin privileges" unless has_admin_privileges?

            command = "sudo -k && echo #{cred.password.shellescape} | sudo -S bash -c \"#{command}\""
          end
        end
        UI.verbose 'Admin privileges granted for command execution'
        command
      end

      def system_no_output(command)
        system(command, out: File::NULL, err: File::NULL)
      end
    end

    private_class_method :execute_command_low, :system_no_output
  end
end
