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

require 'u3d/log_analyzer'
require 'json'

class CustomExpectations
  include RSpec::Matchers

  def phase_active(phases)
    expect(phases).to have_key('TEST_ACTIVE')
  end

  def phase_not_active(phases)
    expect(phases).not_to have_key('TEST_NOT_ACTIVE')
  end

  def silent_phase_use(phases)
    expect(phases).to have_key('TEST')
  end

  def silent_phase_rules(phases)
    expect(phases['TEST']['rules']).to be_empty
  end

  def phase_start_pattern_parsing(phases)
    expect(phases['TEST']['phase_start_pattern']).to eql(/This is a pattern/)
  end
end

rules_data_file = File.expand_path('../../data/rules_data.json', __FILE__)

describe U3d do
  describe U3d::LogAnalyzer do
    describe '.load_rules custom' do
      data = JSON.parse(File.read(rules_data_file))
      data.each do |key, test_cases|
        it test_cases['message'] do
          allow(File).to receive(:read) { test_cases['ruleset'].to_json }

          _gen, parsed_phases = U3d::LogAnalyzer.new.load_rules
          CustomExpectations.new.public_send(key, parsed_phases)
        end
      end
    end
    describe '.load_rules default' do
      it "loads defaults rules without problem" do
        gen, phases = U3d::LogAnalyzer.new.load_rules
        expect(gen.keys.count).to be > 5
        expect(phases.keys).to eq %w[JENKINS INIT COMPILER ASSET]
      end

      it "parses a simple file" do
        log = File.expand_path('../../fixtures/simple_editor.log', __FILE__)
        analyzer = U3d::LogAnalyzer.new
        File.open(log, 'r') do |f|
          f.readlines.each { |l| analyzer.parse_line l }
        end
        # FIXME: we're not really testing anything here
      end
    end
  end
end
