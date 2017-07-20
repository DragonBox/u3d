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

require 'json'

module U3d
  # Analyzes log by filtering output along a set of rules
  class LogAnalyzer
    RULES_PATH = File.expand_path('../../../config/log_rules.json', __FILE__)
    MEMORY_SIZE = 10
    class << self
      def load_rules
        data = {}
        generic_rules = {}
        phases = {}
        File.open(RULES_PATH, 'r') do |f|
          data = JSON.parse(f.read)
        end
        if data['GENERAL'] && data['GENERAL']['active']
          data['GENERAL']['rules'].each do |rn, r|
            generic_rules[rn] = r if parse_rule(r)
          end
        end
        data.delete('GENERAL')
        data.each do |name, phase|
          # Phase parsing
          next unless phase['active']
          next if phase['phase_start_pattern'].nil?
          phase['phase_start_pattern'] = Regexp.new phase['phase_start_pattern']
          phase['phase_end_pattern'] = Regexp.new phase['phase_end_pattern'] if phase['phase_end_pattern']
          phase.delete('comment')
          # Rules parsing
          temp_rules = {}
          unless phase['silent'] == true
            phase['rules'].each do |rn, r|
              temp_rules[rn] = r if parse_rule(r)
            end
          end
          phase['rules'] = temp_rules
          phases[name] = phase
        end
        return generic_rules, phases
      end

      def pipe(i, sleep_time: 0.0)
        lines_memory = Array.new(MEMORY_SIZE)
        active_phase = nil
        active_rule = nil
        context = {}
        rule_lines_buffer = []
        generic_rules, phases = load_rules
        begin
          loop do
            select([i])
            line = i.readline
            # Insert new line and remove last stored line
            lines_memory.push(line).shift

            # Check if phase is changing
            phases.each do |name, phase|
              next if name == active_phase
              next unless line =~ phase['phase_start_pattern']
              if active_rule
                # Active rule should be finished
                # If it is still active during phase change, it means that something went wrong
                UI.error("[#{active_phase}] Could not finish active rule '#{active_rule}'. Aborting it.")
                active_rule = nil
              end
              active_phase = name
              context.clear
              rule_lines_buffer.clear
              UI.verbose("--- Beginning #{name} phase ---")
              break
            end

            apply_ruleset = lambda do |ruleset, header|
              # Apply the active rule
              if active_rule && ruleset[active_rule]
                rule = ruleset[active_rule]
                pattern = rule['end_pattern']

                # Is it the end of the rule?
                if line =~ pattern
                  unless rule_lines_buffer.empty?
                    rule_lines_buffer.each do |l|
                      UI.send(rule['type'], "[#{header}] " + l)
                    end
                  end
                  if rule['end_message'] != false
                    if rule['end_message']
                      match = line.match(pattern)
                      params = match.names.map { |n| n.to_sym }.zip(match.captures).to_h
                      message = rule['end_message'] % params.merge(context)
                    else
                      message = line.chomp
                    end
                    message = "[#{header}] " + message
                    UI.send(rule['type'], message)
                  end
                  active_rule = nil
                  context.clear
                  rule_lines_buffer.clear

                # It's not the end of the rules, should the line be stored?
                elsif rule['store_lines']
                  match = false
                  if rule['ignore_lines']
                    rule['ignore_lines'].each do |pat|
                      if line =~ pat
                        match = true
                        break
                      end
                    end
                  end
                  rule_lines_buffer << line.chomp unless match
                end
              end

              # If there is no active rule, try to apply a new one
              if active_rule.nil?
                ruleset.each do |rn, r|
                  pattern = r['start_pattern']
                  next unless line =~ pattern
                  active_rule = rn if r['end_pattern']
                  match = line.match(pattern)
                  context = match.names.map { |n| n.to_sym }.zip(match.captures).to_h
                  if r['fetch_line_at_index'] || r['fetch_first_line_not_matching']
                    if r['fetch_line_at_index']
                      fetched_line = lines_memory.reverse[r['fetch_line_at_index']]
                    else
                      fetched_line = nil
                      lines_memory.reverse.each do |l|
                        match = false
                        r['fetch_first_line_not_matching'].each do |pat|
                          next unless l =~ pat
                          match = true
                          break
                        end
                        next if match
                        fetched_line = l
                        break
                      end
                    end
                    if fetched_line
                      if r['fetched_line_pattern']
                        match = fetched_line.match(r['fetched_line_pattern'])
                        context.merge!(match.names.map { |n| n.to_sym }.zip(match.captures).to_h)
                      end
                      if r['fetched_line_message'] != false
                        if r['fetched_line_message']
                          message = r['fetched_line_message'] % context
                        else
                          message = fetched_line.chomp
                        end
                        message = "[#{header}] " + message
                        UI.send(r['type'], message)
                      end
                    end
                  end
                  if r['start_message'] != false
                    if r['start_message']
                      message = r['start_message'] % context
                    else
                      message = line.chomp
                    end
                    message = "[#{header}] " + message
                    UI.send(r['type'], message)
                  end
                  break
                end
              end
            end

            apply_ruleset.call(phases[active_phase]['rules'], active_phase) if active_phase
            apply_ruleset.call(generic_rules, 'GENERAL')

            sleep(sleep_time)
          end
        rescue EOFError
          UI.verbose 'End of file'
        rescue Interrupt
          UI.verbose 'Interrupted'
        end
      end

      private

      def parse_rule(r)
        return false unless r['active']
        return false if r['start_pattern'].nil?
        r['start_pattern'] = Regexp.new r['start_pattern']
        r['end_pattern'] = Regexp.new r['end_pattern'] if r['end_pattern']
        if r['fetch_line_at_index']
          r.delete('fetch_line_at_index') if r['fetch_line_at_index'] >= MEMORY_SIZE
          r.delete('fetch_line_at_index') if r['fetch_line_at_index'] <= 0
        elsif r['fetch_first_line_not_matching']
          r['fetch_first_line_not_matching'].map! { |pat| Regexp.new pat }
        end
        if r['fetch_line_at_index'] || r['fetch_first_line_not_matching']
          r['fetched_line_pattern'] = Regexp.new r['fetched_line_pattern'] if r['fetched_line_pattern']
        end
        r['type'] = 'important' if r['type'] == 'warning'
        if r['type'] && r['type'] != 'error' && r['type'] != 'important' && r['type'] != 'success'
          r['type'] = 'message'
        end
        r['type'] ||= 'message'
        r['ignore_lines'].map! { |pat| Regexp.new pat } if r['ignore_lines']
        true
      end
    end
  end
end
