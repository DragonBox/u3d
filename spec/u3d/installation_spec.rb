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

require 'u3d/installation'
require 'support/installations'

describe U3d do
  describe U3d::Installation do
    describe ".create" do
      context "Mac installation" do
        it "creates a Mac installation" do
          allow(U3d::Helper).to receive(:mac?) { true }
          allow(U3d::Helper).to receive(:linux?) { false }

          unity = U3d::Installation.create(path: '/Applications/Unity_5.6.0f1/Unity.app')

          expect(unity.class).to eq(U3d::MacInstallation)
          expect(unity.path).to eq('/Applications/Unity_5.6.0f1/Unity.app')
          expect(unity.exe_path).to eq('/Applications/Unity_5.6.0f1/Unity.app/Contents/MacOS/Unity')
          expect(unity.clean_install?).to eq(true)
          expect(unity.root_path).to eq('/Applications/Unity_5.6.0f1')
        end
      end

      context "Linux installation" do
        it "creates a Linux installation" do
          allow(U3d::Helper).to receive(:mac?) { false }
          allow(U3d::Helper).to receive(:linux?) { true }

          unity = U3d::Installation.create(path: '/opt/unity-editor-5.6.0f1')

          expect(unity.class).to eq(U3d::LinuxInstallation)
          expect(unity.path).to eq('/opt/unity-editor-5.6.0f1')
          expect(unity.root_path).to eq(unity.path)
        end
      end

      context "Windows installation" do
        it "creates a Windows installation" do
          allow(U3d::Helper).to receive(:mac?) { false }
          allow(U3d::Helper).to receive(:linux?) { false }

          unity = U3d::Installation.create(path: 'C:/Program Files/Unity_2017.1.0f3')

          expect(unity.class).to eq(U3d::WindowsInstallation)
          expect(unity.path).to eq('C:/Program Files/Unity_2017.1.0f3')
          expect(unity.root_path).to eq(unity.path)
        end
      end
    end
  end
end
