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

module U3dCore
  # Shell is the terminal output of things
  # For documentation for each of the methods open `interface.rb`
  class Shell < Interface
    def log
      return @log if @log

      $stdout.sync = true

      if Helper.test?
        @log ||= Logger.new(nil) # don't show any logs when running tests
      else
        @log ||= Logger.new($stdout)
      end

      @log.formatter = proc do |severity, datetime, progname, msg|
        "#{format_string(datetime, severity)}#{msg}\n"
      end

      @log
    end

    def format_string(datetime = Time.now, severity = "")
      if $verbose
        return "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: "
      elsif ENV["U3D_HIDE_TIMESTAMP"]
        return ""
      else
        return "[#{datetime.strftime('%H:%M:%S')}]: "
      end
    end

    #####################################################
    # @!group Messaging: show text to the user
    #####################################################

    def error(message)
      log.error(message.to_s.red)
    end

    def important(message)
      log.warn(message.to_s.yellow)
    end

    def success(message)
      log.info(message.to_s.green)
    end

    def message(message)
      log.info(message.to_s)
    end

    def deprecated(message)
      log.error(message.to_s.bold.blue)
    end

    def command(message)
      log.info("$ #{message}".cyan.underline)
    end

    def command_output(message)
      actual = (message.split("\r").last || "") # as clearing the line will remove the `>` and the time stamp
      actual.split("\n").each do |msg|
        prefix = msg.include?("▸") ? "" : "▸ "
        log.info(prefix + "" + msg.magenta)
      end
    end

    def verbose(message)
      log.debug(message.to_s) if $verbose
    end

    def header(message)
      i = message.length + 8
      success("-" * i)
      success("--- " + message + " ---")
      success("-" * i)
    end

    #####################################################
    # @!group Errors: Inputs
    #####################################################

    def interactive?
      interactive = true
      interactive = false if $stdout.isatty == false
      interactive = false if Helper.ci?
      return interactive
    end

    def input(message)
      verify_interactive!(message)
      ask(message.to_s.yellow).to_s.strip
    end

    def confirm(message)
      verify_interactive!(message)
      agree("#{message} (y/n)".yellow, true)
    end

    def select(message, options)
      verify_interactive!(message)

      important(message)
      choose(*options)
    end

    def password(message)
      verify_interactive!(message)

      ask(message.yellow) { |q| q.echo = "*" }
    end

    private

    def verify_interactive!(message)
      return if interactive?
      important(message)
      crash!("Could not retrieve response as u3d runs in non-interactive mode")
    end
  end
end
