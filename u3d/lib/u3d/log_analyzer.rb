require 'json'

module U3d
  class LogAnalyzer
    RULES_PATH = File.expand_path('../../../config/log_rules.json', __FILE__)
    class << self
      def load_rules
        data = {}
        rules = {}
        File.open(RULES_PATH, 'r') do |f|
          data = JSON.parse(f.read)
        end
        data.each do |name, r|
          next unless r['active']
          r['start_pattern'] = Regexp.new r['start_pattern'] if r['start_pattern']
          r['end_pattern'] = Regexp.new r['end_pattern'] if r['end_pattern']
          rules[name] = r
        end
        puts rules
        rules
      end

      def pipe(i, sleep_time: 0.0)
        active_rule = nil
        lines_buffer = []
        rules = load_rules
        begin
          while true do
            select([i])
            line = i.readline
            if active_rule
              pattern = active_rule['end_pattern']
              if line =~ pattern
                time = line.match(pattern)[:time]
                if active_rule['end_message']
                  message = active_rule['end_message']
                  message += " (#{time} seconds)" if time
                else
                  message = line.chomp
                end
                UI.message message
                active_rule = nil
                lines_buffer.clear
              else
                lines_buffer << line if active_rule['store_lines']
              end
            else
              rules.values.each do |rule|
                if line =~ rule['start_pattern']
                  if rule['end_pattern']
                    active_rule = rule
                  end
                  if rule['start_message']
                    UI.message rule['start_message']
                  else
                    UI.message line.chomp
                  end
                  break
                end
              end
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
