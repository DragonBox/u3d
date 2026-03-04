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
