# frozen_string_literal: true

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
require 'u3d/failure_reporter'

module U3d
  # Analyzes log by filtering output along a set of rules
  # rubocop:disable Metrics/ClassLength, Metrics/PerceivedComplexity, Metrics/BlockNesting
  class LogAnalyzer
    RULES_PATH = File.expand_path('../../config/log_rules.json', __dir__)
    MEMORY_SIZE = 10

    def initialize
      @lines_memory = Array.new(MEMORY_SIZE)
      @active_phase = nil
      @active_rule = nil
      @context = {}
      @rule_lines_buffer = []
      @generic_rules, @phases = load_rules
    end

    def load_rules
      generic_rules = {}
      phases = {}

      data = JSON.parse(File.read(rules_path))

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

    def parse_line(line)
      # Insert new line and remove last stored line
      @lines_memory.push(line).shift

      # Check if phase is changing
      @phases.each do |name, phase|
        next if name == @active_phase
        next unless line =~ phase['phase_start_pattern']

        finish_phase if @active_phase
        @active_phase = name
        UI.verbose("--- Beginning #{name} phase ---")
        break
      end

      apply_ruleset = lambda do |ruleset, header|
        # Apply the active rule
        if @active_rule && ruleset[@active_rule]
          rule = ruleset[@active_rule]
          pattern = rule['end_pattern']

          # Is it the end of the rule?
          if line =~ pattern
            unless @rule_lines_buffer.empty?
              @rule_lines_buffer.each do |l|
                UI.send(rule['type'], "[#{header}] " + l)
              end
            end
            if rule['end_message'] != false
              if rule['end_message']
                match = line.match(pattern)
                params = match.names.map(&:to_sym).zip(match.captures).to_h
                message = inject(rule['end_message'], params: params)
              else
                message = line.chomp
              end
              message = "[#{header}] " + message
              UI.send(rule['type'], message)
            end
            @active_rule = nil
            @context.clear
            @rule_lines_buffer.clear

          # It's not the end of the rules, should the line be stored?
          elsif rule['store_lines']
            match = false
            rule['ignore_lines']&.each do |pat|
              if line =~ pat
                match = true
                break
              end
            end
            @rule_lines_buffer << line.chomp unless match
          end
        end

        # If there is no active rule, try to apply a new one
        if @active_rule.nil?
          ruleset.each do |rn, r|
            pattern = r['start_pattern']
            next unless line =~ pattern

            @active_rule = rn if r['end_pattern']
            match = line.match(pattern)
            @context = match.names.map(&:to_sym).zip(match.captures).to_h
            if r['fetch_line_at_index'] || r['fetch_first_line_not_matching']
              if r['fetch_line_at_index']
                fetched_line = @lines_memory.reverse[r['fetch_line_at_index']]
              else
                fetched_line = nil
                @lines_memory.reverse.each do |l|
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
                  @context.merge!(match.names.map(&:to_sym).zip(match.captures).to_h)
                end
                if r['fetched_line_message'] != false
                  message = if r['fetched_line_message']
                              inject(r['fetched_line_message'])
                            else
                              fetched_line.chomp
                            end
                  message = "[#{header}] " + message
                  UI.send(r['type'], message)
                end
              end
            end
            if r['start_message'] != false
              message = if r['start_message']
                          inject(r['start_message'])
                        else
                          line.chomp
                        end
              message = "[#{header}] " + message
              UI.send(r['type'], message)
            end
            break
          end
        end
      end

      if @active_phase
        apply_ruleset.call(@phases[@active_phase]['rules'], @active_phase)
        finish_phase if @phases[@active_phase]['phase_end_pattern'] && @phases[@active_phase]['phase_end_pattern'] =~ line
      end
      apply_ruleset.call(@generic_rules, 'GENERAL')
    end

    private

    def finish_phase
      if @active_rule
        # Active rule should be finished
        # If it is still active during phase change, it means that something went wrong
        context = @lines_memory.map { |l| "> #{l}" }.join
        UI.error("[#{@active_phase}] Could not finish active rule '#{@active_rule}'. Aborting it. Context:\n#{context}")

        U3d::FailureReporter.report(
          failure_type: "PRETTIFIER",
          failure_message: "Could not finish rule",
          data: {
            phase: @active_phase,
            rule: @active_rule,
            context: context.split("\n")
          }
        )

        @active_rule = nil
      end
      UI.verbose("--- Ending #{@active_phase} phase ---")
      @active_phase = nil
      @context.clear
      @rule_lines_buffer.clear
    end

    def rules_path
      path = ENV["U3D_RULES_PATH"]
      unless path.nil?
        UI.user_error!("Specified rules path '#{path}' isn't a file") unless File.exist? path
        UI.message("Using #{path} for prettify rules path")
      end
      path = RULES_PATH if path.nil?
      path
    end

    def inject(string, params: {})
      message = "This is a default message."
      begin
        message = string % params.merge(@context)
      rescue KeyError => e
        UI.error("[U3D] Rule '#{@active_rule}' captures were incomplete: #{e.message}")
      end
      message
    end

    def parse_rule(rule)
      return false unless rule['active']
      return false if rule['start_pattern'].nil?

      rule['start_pattern'] = Regexp.new rule['start_pattern']
      rule['end_pattern'] = Regexp.new rule['end_pattern'] if rule['end_pattern']
      if rule['fetch_line_at_index']
        rule.delete('fetch_line_at_index') if rule['fetch_line_at_index'] >= MEMORY_SIZE
        rule.delete('fetch_line_at_index') if rule['fetch_line_at_index'] <= 0
      elsif rule['fetch_first_line_not_matching']
        rule['fetch_first_line_not_matching'].map! { |pat| Regexp.new pat }
      end
      rule['fetched_line_pattern'] = Regexp.new rule['fetched_line_pattern'] if (rule['fetch_line_at_index'] || rule['fetch_first_line_not_matching']) && (rule['fetched_line_pattern'])
      rule['type'] = 'important' if rule['type'] == 'warning'
      rule['type'] = 'message' if rule['type'] && rule['type'] != 'error' && rule['type'] != 'important' && rule['type'] != 'success'
      rule['type'] ||= 'message'
      rule['ignore_lines']&.map! { |pat| Regexp.new pat }
      true
    end
  end
  # rubocop:enable Metrics/ClassLength, Metrics/PerceivedComplexity, Metrics/BlockNesting
end
