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

require 'u3d/utils'
require 'fileutils'
require 'file-tail'

module U3d
  # Launches Unity with given arguments
  class Runner
    def run(installation, args, raw_logs: false)
      log_file = find_and_prepare_logfile(installation, args)

      tail_thread = Thread.new do
        begin
          if raw_logs
            pipe(log_file) { |l| UI.message l.rstrip }
          else
            analyzer = LogAnalyzer.new
            pipe(log_file) { |l| analyzer.parse_line l }
          end
        rescue => e
          UI.error "Failure while trying to pipe #{log_file}: #{e.message}"
          e.backtrace.each { |l| UI.error "  #{l}" }
        end
      end

      # Wait for tail_thread setup to be complete
      sleep 0.5 while tail_thread.status == 'run'
      return unless tail_thread.status
      tail_thread.run

      begin
        args.unshift(installation.exe_path)
        if Helper.windows?
          args.map! { |a| a =~ / / ? "\"#{a}\"" : a }
        else
          args.map!(&:shellescape)
        end

        output_callback = Proc.new do |line|
          UI.command_output(line)
        end

        U3dCore::CommandExecutor.execute_command(command: args, output_callback: output_callback)
      ensure
        sleep 1
        Thread.kill(tail_thread)
      end
    end

    def find_and_prepare_logfile(installation, args)
      log_file = Runner.find_logFile_in_args(args)

      if log_file # we wouldn't want to do that for the default log file.
        File.delete(log_file) if File.file?(log_file) # We only delete real files
      else
        log_file = installation.default_log_file
      end

      Utils.ensure_dir File.dirname(log_file)
      FileUtils.touch(log_file) unless File.exist? log_file
      log_file
    end

    class << self
      # rubocop:disable MethodName
      def find_logFile_in_args(args)
        # rubocop:enable MethodName
        find_arg_in_args('-logFile', args)
      end

      def find_projectpath_in_args(args)
        find_arg_in_args('-projectpath', args)
      end

      def find_arg_in_args(arg_to_find, args)
        raise 'Only arguments of type array supported right now' unless args.is_a?(Array)
        args.each_with_index do |arg, index|
          return args[index + 1] if arg == arg_to_find && index < args.count - 1
        end
        nil
      end
    end

    private

    def pipe(file)
      File.open(file, 'r') do |f|
        f.extend File::Tail
        f.interval = 0.1
        f.max_interval = 0.4
        f.backward 0
        Thread.stop
        f.tail { |l| yield l }
      end
    end
  end
end
