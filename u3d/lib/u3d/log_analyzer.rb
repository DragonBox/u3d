module U3d
  class LogAnalyzer
    MONO_INI = 'initialize mono'.freeze
    

    class << self
      def pipe(i, sleep_time: 0.0)
        buffer = {
          type: nil,
          message: nil,
          expected_pattern: nil
          lines: []
        }
        begin
          while true do
            line = i.readline

            sleep(sleep_time)
          end
        rescue EOFerror
          UI.verbose 'End of file'
        rescue Interrupt
          UI.verbose 'Interrupted'
        end
      end
    end
  end
end
