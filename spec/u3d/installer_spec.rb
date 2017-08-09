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

require 'u3d/installer'
require 'support/installations'

describe U3d do
  describe U3d::Installer do
    describe U3d::MacInstaller do
      context 'when using a default install' do
        let(:unity) { macinstall_5_6_default }
        it 'sanitizes install' do
          expect(U3d::UI).to receive(:important).with("Moving /Applications/Unity to /Applications/Unity_5.6.0f1...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "mv /Applications/Unity /Applications/Unity_5.6.0f1", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully moved /Applications/Unity to /Applications/Unity_5.6.0f1")
          U3d::MacInstaller.new.sanitize_install(unity)
        end
      end

      context 'when using a custom install with spaces' do
        let(:unity) { macinstall_5_6_custom_with_space }
        it 'sanitizes install' do
          expect(U3d::UI).to receive(:important).with("Moving /Applications/Unity 5.6.0f1 to /Applications/Unity_5.6.0f1...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "mv \"/Applications/Unity 5.6.0f1\" /Applications/Unity_5.6.0f1", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully moved \"/Applications/Unity 5.6.0f1\" to /Applications/Unity_5.6.0f1")
          U3d::MacInstaller.new.sanitize_install(unity)
        end
      end
    end
  end
end
