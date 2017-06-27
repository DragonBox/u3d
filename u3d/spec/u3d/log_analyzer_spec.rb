require 'u3d/log_analyzer'
require 'json'

include RSpec::Matchers
expectations = {
  'phase_active' => Proc.new do |phases|
    expect(phases).to have_key('TEST_ACTIVE')
  end,
  'phase_not_active' => Proc.new do |phases|
    expect(phases).not_to have_key('TEST_NOT_ACTIVE')
  end,
  'silent_phase_use' => Proc.new do |phases|
    expect(phases).to have_key('TEST')
  end,
  'silent_phase_rules' => Proc.new do |phases|
    expect(phases['TEST']['rules']).to be_empty
  end
}
rules_data_file = File.expand_path('../../data/rules_data.json', __FILE__)

describe U3d do
  describe U3d::LogAnalyzer do
    describe '.load_rules' do
      data = {}
      File.open(rules_data_file, 'r') do |f|
        data = JSON.parse(f.read)
      end
      data.each do |key, test_cases|
        it "#{test_cases['message']}" do
          file = double('file')
          allow(File).to receive(:open).with(anything, 'r').and_yield(file)
          allow(file).to receive(:read) { test_cases['ruleset'].to_json }

          _gen, parsed_phases = U3d::LogAnalyzer.load_rules
          expectations[key].call(parsed_phases)
        end
      end
    end
  end
end
