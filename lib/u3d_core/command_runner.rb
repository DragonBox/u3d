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

require 'English'

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
        rescue LoadError
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
          trap('INT') do
            Process.kill("INT", p)
          end
          yield r, w, p
        # if the process has closed, ruby might raise an exception if we try
        # to do I/O on a closed stream. This behavior is platform specific
        # rubocop:disable HandleExceptions
        rescue Errno::EIO
        # rubocop:enable HandleExceptions
        ensure
          begin
            Process.wait p
          # The process might have exited.
          # This behavior is also ruby version dependent.
          # rubocop:disable HandleExceptions
          rescue Errno::ECHILD, PTY::ChildExited
          end
          # rubocop:enable HandleExceptions
        end
      end
      $CHILD_STATUS.exitstatus
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
