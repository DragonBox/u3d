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

      @log ||= if Helper.is_test?
                 Logger.new(nil) # don't show any logs when running tests
               else
                 Logger.new($stdout)
               end

      @log.formatter = proc do |severity, datetime, _progname, msg|
        "#{format_string(datetime, severity)}#{msg}\n"
      end

      require 'u3d_core/ui/disable_colors' if U3dCore::Helper.colors_disabled?

      @log
    end

    def format_string(datetime = Time.now, severity = "")
      if U3dCore::Globals.log_timestamps?
        timestamp = ENV["U3D_UI_TIMESTAMP"]
        # default timestamp if none specified
        unless timestamp
          timestamp = if U3dCore::Globals.verbose?
                        '%Y-%m-%d %H:%M:%S.%2N'
                      else
                        '%H:%M:%S'
                      end
        end
      end
      # hide has last word
      timestamp = nil if ENV["U3D_HIDE_TIMESTAMP"]
      s = []
      s << "#{severity} " if U3dCore::Globals.verbose? && severity && !severity.empty?
      s << "[#{datetime.strftime(timestamp)}] " if timestamp
      s.join('')
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
      log.debug(message.to_s) if U3dCore::Globals.verbose?
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
      ask("#{format_string}#{message.to_s.yellow}").to_s.strip
    end

    def confirm(message)
      verify_interactive!(message)
      agree("#{format_string}#{message.to_s.yellow} (y/n)", true)
    end

    def select(message, options)
      verify_interactive!(message)

      important(message)
      choose(*options)
    end

    def password(message)
      verify_interactive!(message)

      ask("#{format_string}#{message.to_s.yellow}") { |q| q.echo = "*" }
    end

    private

    def verify_interactive!(message)
      return if interactive?
      important(message)
      crash!("Could not retrieve response as u3d runs in non-interactive mode")
    end
  end
end
