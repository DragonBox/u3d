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
require 'support/setups'
require 'support/installations'

describe U3d do
  describe U3d::Installation do
    describe ".create" do
      context "Mac installation" do
        before(:each) do
          on_mac
        end

        it "supports deprecated .path" do
          unity = U3d::Installation.create(path: '/Applications/Unity_5.6.0f1/Unity.app')
          expect(unity.path).to eq('/Applications/Unity_5.6.0f1/Unity.app')
        end

        it "detects non clean install based on path name" do
          unity = U3d::Installation.create(root_path: '/Applications/Unity/Unity.app')
          expect(unity.clean_install?).to eq(false)
        end

        it "creates a Mac installation" do
          unity = U3d::Installation.create(root_path: '/Applications/Unity_5.6.0f1')

          expect(unity.class).to eq(U3d::MacInstallation)
          expect(unity.path).to eq('/Applications/Unity_5.6.0f1/Unity.app')
          expect(unity.exe_path).to eq('/Applications/Unity_5.6.0f1/Unity.app/Contents/MacOS/Unity')
          expect(unity.clean_install?).to eq(true)
          expect(unity.do_not_move?).to eq(false)
          expect(unity.root_path).to eq('/Applications/Unity_5.6.0f1')
        end
      end

      context "Linux installation" do
        before(:each) do
          on_linux
        end

        it "supports deprecated .path" do
          unity = U3d::Installation.create(path: '/opt/unity-editor-5.6.0f1')
          expect(unity.path).to eq('/opt/unity-editor-5.6.0f1')
        end

        it "detects non clean install based on path name" do
          unity = U3d::Installation.create(root_path: '/opt/unity-editor')
          expect(unity.clean_install?).to eq(false)
        end

        it "creates a Linux installation" do
          unity = U3d::Installation.create(root_path: '/opt/unity-editor-5.6.0f1')

          expect(unity.class).to eq(U3d::LinuxInstallation)
          expect(unity.path).to eq('/opt/unity-editor-5.6.0f1')
          expect(unity.clean_install?).to eq(true)
          expect(unity.do_not_move?).to eq(false)
          expect(unity.root_path).to eq('/opt/unity-editor-5.6.0f1')
        end
      end

      context "Windows installation" do
        before(:each) do
          on_windows
        end

        it "supports deprecated .path" do
          unity = U3d::Installation.create(path: 'C:/Program Files/Unity_2017.1.0f3')
          expect(unity.path).to eq('C:/Program Files/Unity_2017.1.0f3')
        end

        it "detects non clean install based on path name" do
          unity = U3d::Installation.create(root_path: 'C:/Program Files/Unity')
          expect(unity.clean_install?).to eq(false)
        end

        it "creates a Windows installation" do
          unity = U3d::Installation.create(root_path: 'C:/Program Files/Unity_2017.1.0f3')

          expect(unity.class).to eq(U3d::WindowsInstallation)
          expect(unity.path).to eq('C:/Program Files/Unity_2017.1.0f3')
          expect(unity.clean_install?).to eq(true)
          expect(unity.do_not_move?).to eq(false)
          expect(unity.root_path).to eq('C:/Program Files/Unity_2017.1.0f3')
        end
      end

      context "Any installation" do
        before(:each) do
          on_mac
        end

        it "supports installations that can move" do
          expect(File).to receive(:exist?).with('/Applications/Unity') { true }
          expect(File).to receive(:exist?).with('/Applications/Unity/.u3d_do_not_move') { false }

          unity = U3d::Installation.create(root_path: '/Applications/Unity')
          expect(unity.send(:do_not_move_file_path)).to eq('/Applications/Unity/.u3d_do_not_move')
          expect(unity.clean_install?).to eq(false)
        end

        it "supports installations that cannot move" do
          expect(File).to receive(:exist?).with('/Applications/Unity') { true }
          expect(File).to receive(:exist?).with('/Applications/Unity/.u3d_do_not_move') { true }

          unity = U3d::Installation.create(root_path: '/Applications/Unity')
          expect(unity.send(:do_not_move_file_path)).to eq('/Applications/Unity/.u3d_do_not_move')
          expect(unity.clean_install?).to eq(true)
        end

        it "supports marking installations to not move" do
          expect(File).to receive(:exist?).with('/Applications/Unity') { true }
          expect(File).to receive(:exist?).with('/Applications/Unity/.u3d_do_not_move') { true }

          unity = U3d::Installation.create(root_path: '/Applications/Unity')
          expect(unity.send(:do_not_move_file_path)).to eq('/Applications/Unity/.u3d_do_not_move')
          expect(unity.clean_install?).to eq(true)
        end
      end
    end
  end
end
