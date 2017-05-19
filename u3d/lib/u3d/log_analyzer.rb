module U3d
  class LogAnalyzer
    MONO_INI = /Initialize mono/

    class << self
      def pipe(i, sleep_time: 0.0)
        buffer = {
          type: nil,
          message: nil,
          expected_pattern: nil,
          lines: []
        }
        begin
          while true do
            select([i])
            line = i.readline
            if line =~ MONO_INI
              UI.message line
            end
            sleep(sleep_time)
          end
        rescue EOFError
          UI.verbose 'End of file'
        rescue Interrupt
          UI.verbose 'Interrupted'
        end
      end
    end
  end
end
