module U3dCore
  # this module is meant to be private to this lib
  module Runner
    class << self
      def run(command, &block)
        select_runner_impl.call(command, &block)
      end

      private

      def select_runner_impl
        # disable PTY by setting env variable
        return U3dCore::SafePopen.method(:spawn) unless ENV['U3D_NO_TTY'].nil?
        begin
          require 'pty'
          return U3dCore::SafePty.method(:spawn)
        rescue
          UI.important("No pty implementation found. Falling back to popen. Output might be buffered")
          return U3dCore::SafePopen.method(:spawn)
        end
      end
    end
  end

  # Executes commands using PTY and takes care of error handling and more
  class SafePty
    # Wraps the PTY.spawn() call, wait until the process completes.
    # Also catch exceptions that might be raised
    # See also https://www.omniref.com/ruby/gems/shell_test/0.5.0/files/lib/shell_test/shell_methods/utils.rb
    def self.spawn(command, &_block)
      require 'pty'
      PTY.spawn(command) do |r, w, p|
        begin
          trap('INT') {
            Process.kill("INT", p)
          }
          yield r, w, p
        # if the process has closed, ruby might raise an exception if we try
        # to do I/O on a closed stream. This behavior is platform specific
        rescue Errno::EIO
        ensure
          begin
            Process.wait p
          # The process might have exited.
          # This behavior is also ruby version dependent.
          rescue Errno::ECHILD, PTY::ChildExited
          end
        end
      end
      $?.exitstatus
    end
  end

  # Executes commands using popen2 and takes care of error handling and more
  # Note that the executed program might buffer the output as it isn't run inside
  # a pseudo terminal.
  class SafePopen
    # Wraps the Open3.popen2e() call, wait until the process completes.
    def self.spawn(command, &_block)
      require 'open3'
      Open3.popen2e(command) do |r, w, p|
        yield w, r, p.value.pid # note the inversion
        r.close
        w.close
        p.value.exitstatus
      end
    end
  end
end