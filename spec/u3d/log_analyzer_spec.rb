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

include RSpec::Matchers
expectations = {
  'phase_active' => proc do |phases|
    expect(phases).to have_key('TEST_ACTIVE')
  end,
  'phase_not_active' => proc do |phases|
    expect(phases).not_to have_key('TEST_NOT_ACTIVE')
  end,
  'silent_phase_use' => proc do |phases|
    expect(phases).to have_key('TEST')
  end,
  'silent_phase_rules' => proc do |phases|
    expect(phases['TEST']['rules']).to be_empty
  end,
  'phase_start_pattern_parsing' => proc do |phases|
    expect(phases['TEST']['phase_start_pattern']).to eql(/This is a pattern/)
  end
}
rules_data_file = File.expand_path('../../data/rules_data.json', __FILE__)

describe U3d do
  describe U3d::LogAnalyzer do
    describe '.load_rules' do
      data =  JSON.parse(File.read(rules_data_file))
      data.each do |key, test_cases|
        it test_cases['message'] do
          file = double('file')
          allow(File).to receive(:read) { test_cases['ruleset'].to_json }

          _gen, parsed_phases = U3d::LogAnalyzer.new.load_rules
          expectations[key].call(parsed_phases)
        end
      end
    end
  end
end
