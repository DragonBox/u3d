require 'json'

module U3d
  class LogAnalyzer
    RULES_PATH = File.expand_path('../../../config/log_rules.json', __FILE__)
    class << self
      def load_rules
        data = {}
        generic_rules = {}
        phases = {}
        File.open(RULES_PATH, 'r') do |f|
          data = JSON.parse(f.read)
        end
        if data['GENERAL'] && data['GENERAL']['active']
          generic_rules = data['GENERAL']['rules']
          data['GENERAL']['rules'].each do |_rn, r|
            next unless r['active']
            next if r['start_pattern'].nil?
            r['start_pattern'] = Regexp.new r['start_pattern']
            r['end_pattern'] = Regexp.new r['end_pattern'] if r['end_pattern']
            r['type'] = 'important' if r['type'] == 'warning'
            if r['type'] && r['type'] != 'error' && r['type'] != 'important'
              r['type'] = 'message'
            end
            r['type'] ||= 'message'
          end
        end
        data.each do |name, phase|
          # Phase parsing
          next unless phase['active']
          next if phase['phase_start_pattern'].nil?
          phase['phase_start_pattern'] = Regexp.new phase['phase_start_pattern']
          phase['phase_end_pattern'] = Regexp.new phase['phase_end_pattern'] if phase['phase_end_pattern']
          phase.delete('comment')
          # Rules parsing
          temp_rules = {}
          phase['rules'].each do |rn, r|
            next unless r['active']
            next if r['start_pattern'].nil?
            r['start_pattern'] = Regexp.new r['start_pattern']
            r['end_pattern'] = Regexp.new r['end_pattern'] if r['end_pattern']
            r['type'] = 'important' if r['type'] == 'warning'
            if r['type'] && r['type'] != 'error' && r['type'] != 'important'
              r['type'] = 'message'
            end
            r['type'] ||= 'message'
            temp_rules[rn] = r
          end
          phase['rules'] = temp_rules
          phases[name] = phase
        end
        return generic_rules, phases
      end

      def pipe(i, sleep_time: 0.0)
        active_phase = nil
        active_rule = nil
        lines_buffer = []
        generic_rules, phases = load_rules
        begin
          while true do
            select([i])
            line = i.readline

            # Check if phase is changing
            phases.each do |name, phase|
              next if name == active_phase
              if line =~ phase['phase_start_pattern']
                if active_rule
                  # Active rule should be finished
                  # If it is still active during phase change, it means that something went wrong
                  UI.error("[#{active_phase}] Could not finish active rule '#{active_rule}'. Aborting it.")
                  active_rule = nil
                end
                active_phase = name
                lines_buffer.clear
                UI.verbose("--- Beginning #{name} phase ---")
                break
              end
            end

            # Try to apply current phase ruleset
            if active_phase
              rules = phases[active_phase]['rules']

              if active_rule
                rule = rules[active_rule]
                pattern = rule['end_pattern']
                if line =~ pattern # Rule ending
                  unless lines_buffer.empty?
                    lines_buffer.each do |l|
                      UI.send(rule['type'], l)
                    end
                  end
                  if rule['end_message'] != false
                    if rule['end_message']
                      match = line.match(pattern)
                      params = match.names.map{ |n| n = n.to_sym }.zip(match.captures).to_h
                      message = rule['end_message'] % params
                    else
                      message = line.chomp
                    end
                    message = "[#{active_phase}] " + message
                    UI.send(rule['type'], message)
                  end
                  active_rule = nil
                  lines_buffer.clear
                  UI.verbose("[#{active_phase}] Ending rule '#{active_rule}'.")
                else
                  lines_buffer << line.chomp if rule['store_lines']
                end
              end

              if active_rule.nil?
                rules.each do |rn, rule|
                  pattern = rule['start_pattern']
                  if line =~ pattern
                    if rule['end_pattern']
                      active_rule = rn
                    end
                    if rule['start_message']
                      match = line.match(pattern)
                      params = match.names.map{ |n| n = n.to_sym }.zip(match.captures).to_h
                      message = rule['start_message'] % params
                    else
                      message = line.chomp
                    end
                    message = "[#{active_phase}] " + message
                    UI.send(rule['type'], message)
                    break
                  end
                end
              end

              if phases[active_phase]['phase_end_pattern'] && line =~ phases[active_phase]['phase_end_pattern']
                if active_rule
                  # Active rule should be finished
                  # If it is still active during phase change, it means that something went wrong
                  UI.error("[#{active_phase}] Could not finish active rule '#{active_rule}'. Aborting it.")
                  active_rule = nil
                end
                lines_buffer.clear
                UI.verbose("---  Ending #{active_phase} phase   ---")
                active_phase = nil
              end
            end

            # Finally, try to apply the generic rules
            generic_rules.each do |name, rule|
              pattern = rule['start_pattern']
              if line =~ pattern
                if rule['end_pattern']
                  UI.important('GENERAL rules only support one line rules at the moment')
                end
                if rule['start_message']
                  match = line.match(pattern)
                  params = match.names.map{ |n| n = n.to_sym }.zip(match.captures).to_h
                  message = rule['start_message'] % params
                else
                  message = line.chomp
                end
                message = "[GENERAL] " + message
                UI.send(rule['type'], message)
                break
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
