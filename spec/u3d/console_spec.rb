require 'irb'
require 'u3d/commands'

describe U3d::Commands do
  describe '.console' do
    let(:irb_instance) { instance_double(IRB::Irb) }
    let(:irb_context) { instance_double(IRB::Context) }

    before do
      allow(IRB).to receive(:setup)
      allow(IRB::Irb).to receive(:new).and_return(irb_instance)
      allow(irb_instance).to receive(:context).and_return(irb_context)
      allow(irb_context).to receive(:prompt_mode=)
      allow(irb_instance).to receive(:signal_handle)
      allow(irb_instance).to receive(:eval_input)

      IRB.conf[:PROMPT] ||= {}
      IRB.conf[:PROMPT][:SIMPLE] ||= {}
    end

    it "sets up IRB with a workspace passed to the constructor" do
      expect(IRB::WorkSpace).to receive(:new).with(an_instance_of(Binding)).and_call_original
      expect(IRB::Irb).to receive(:new).with(an_instance_of(IRB::WorkSpace)).and_return(irb_instance)

      U3d::Commands.console
    end

    it "configures the U3D prompt mode" do
      expect(irb_context).to receive(:prompt_mode=).with(:U3D)

      U3d::Commands.console

      expect(IRB.conf[:PROMPT][:U3D][:RETURN]).to eq("%s\n")
    end

    it "displays the welcome message" do
      expect(U3d::UI).to receive(:message).with('Welcome to u3d interactive!')

      U3d::Commands.console
    end

    it "starts the IRB eval loop" do
      expect(irb_instance).to receive(:eval_input)

      U3d::Commands.console
    end
  end
end
