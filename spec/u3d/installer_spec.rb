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

require 'u3d/installer'
require 'support/installations'

module U3d
  class DummyInstaller < U3d::BaseInstaller
  end
end
describe U3d do
  describe U3d::Installer do
    describe U3d::BaseInstaller do
      describe ".sanitize_installs" do
        context "Clean installs" do
          it "allows to list the installed versions and doesn't ask for sanitization" do
            allow(U3d::Helper).to receive(:mac?) { false }
            allow(U3d::Helper).to receive(:linux?) { true }
            allow(U3dCore::UI).to receive(:confirm).with(/2 Unity .* will be moved/) { 'y' }

            installed = [linux_5_6_standard]

            installer = U3d::DummyInstaller.new
            allow(installer).to receive(:new) { installer }
            allow(installer).to receive(:installed) { installed }

            expect(U3d::UI).to_not receive(:important)
            expect(installer).to_not receive(:sanitize_install)

            installer.sanitize_installs
          end
        end

        context "Unclean installs" do
          it "allows to list the installed versions and ask for sanitization" do
            allow(U3d::Helper).to receive(:mac?) { true }
            allow(U3dCore::UI).to receive(:confirm).with(/2 Unity .* will be moved/) { 'y' }
            installed = [macinstall_5_6_custom_with_space, macinstall_5_6_default]

            installer = U3d::DummyInstaller.new
            allow(installer).to receive(:installed) { installed }

            expect(U3d::UI).to receive(:important).with(/u3d can optionally standardize/)
            expect(U3d::UI).to receive(:important).with(/Check the documentation/)
            expect(U3d::UI).to receive(:important).with(/github.com/)

            expect(installer).to receive(:sanitize_install).with(installed[0], dry_run: true)
            expect(installer).to receive(:sanitize_install).with(installed[1], dry_run: true)

            expect(installer).to receive(:sanitize_install).with(installed[0])
            expect(installer).to receive(:sanitize_install).with(installed[1])

            installer.sanitize_installs
          end
        end
      end

      describe ".installed_sorted_by_versions" do
        it "sorts by version" do
          i1 = fake_installation('1.2.3f6')
          i2 = fake_installation('1.2.3b2')
          i3 = fake_installation('1.2.3f4')
          i4 = fake_installation('1.2.3f5-MLTP8.1')

          installed = [i1, i2, i3, i4]
          sorted_installed = [i2, i3, i4, i1]

          installer = U3d::DummyInstaller.new
          allow(installer).to receive(:installed) { installed }

          expect(installer.installed_sorted_by_versions).to eq(sorted_installed)
        end
      end

      describe ".extra_installation_paths" do
        describe "converts paths to ruby paths" do
          def expect_extra_installation_paths(env_var, expected_paths)
            installer = U3d::DummyInstaller.new
            with_env_values('U3D_EXTRA_PATHS' => env_var) do
              expect(installer.send(:extra_installation_paths)).to eql(expected_paths)
            end
          end
          it "works on Windows", if: WINDOWS do
            expect_extra_installation_paths(
              "C:\\Program Files\\Unity;D:\\",
              ["C:/Program Files/Unity", "D:/"]
            )
          end

          it "works on Unix", unless: WINDOWS do
            expect_extra_installation_paths(
              "/Applications/here:/Applications/else",
              ["/Applications/here", "/Applications/else"]
            )
          end
        end
      end
    end

    describe U3d::MacInstaller, unless: WINDOWS do
      describe '.list' do
        it 'finds installs in default locations' do
          unity = macinstall_5_6_default
          installer = U3d::MacInstaller.new

          allow(Dir).to receive(:glob).with('/Applications/Unity*/Unity.app') { ["#{unity.root_path}/Unity.app"] }
          allow(U3d::MacInstallation).to receive(:new).with(root_path: unity.root_path) { unity }
          allow(installer).to receive(:spotlight_installed_paths) { [] }

          expect(installer.installed).to eql [unity]
        end

        it 'does not find installs in custom locations without U3D_EXTRA_PATHS' do
          unity = macinstall_5_6_custom_location
          installer = U3d::MacInstaller.new

          allow(Dir).to receive(:glob).with('/Applications/Unity*/Unity.app') { [] }
          allow(Dir).to receive(:glob).with('/tmp/Applications/Unity*/Unity.app') { ["#{unity.root_path}/Unity.app"] }
          allow(U3d::MacInstallation).to receive(:new).with(root_path: unity.root_path) { unity }
          allow(installer).to receive(:spotlight_installed_paths) { [] }

          expect(installer.installed).to eql []
        end

        it 'finds installs in custom locations with U3D_EXTRA_PATHS' do
          unity = macinstall_5_6_custom_location
          installer = U3d::MacInstaller.new

          allow(ENV).to receive(:[]).with('U3D_EXTRA_PATHS') { '/tmp' }
          allow(Dir).to receive(:glob).with('/Applications/Unity*/Unity.app') { [] }
          allow(Dir).to receive(:glob).with('/tmp/Applications/Unity*/Unity.app') { ["#{unity.root_path}/Unity.app"] }
          allow(U3d::MacInstallation).to receive(:new).with(root_path: unity.root_path) { unity }
          allow(installer).to receive(:spotlight_installed_paths) { [] }

          expect(installer.installed).to eql [unity]
        end

        it 'finds both custom and default installs' do
          unity_default = macinstall_5_6_default
          unity_custom = macinstall_5_6_custom_location
          installer = U3d::MacInstaller.new

          allow(ENV).to receive(:[]).with('U3D_EXTRA_PATHS') { '/tmp' }
          allow(Dir).to receive(:glob).with('/Applications/Unity*/Unity.app') { ["#{unity_default.root_path}/Unity.app"] }
          allow(Dir).to receive(:glob).with('/tmp/Applications/Unity*/Unity.app') { ["#{unity_custom.root_path}/Unity.app"] }
          allow(U3d::MacInstallation).to receive(:new).with(root_path: unity_default.root_path) { unity_default }
          allow(U3d::MacInstallation).to receive(:new).with(root_path: unity_custom.root_path) { unity_custom }
          allow(installer).to receive(:spotlight_installed_paths) { [] }

          expect(installer.installed).to eql [unity_default, unity_custom]
        end
      end

      context 'when using a default install' do
        let(:unity) { macinstall_5_6_default }
        it 'sanitizes install' do
          expect(U3d::UI).to receive(:important).with("Moving '/Applications/Unity' to '/Applications/Unity_5.6.0f1'...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "mv /Applications/Unity /Applications/Unity_5.6.0f1", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully moved '/Applications/Unity' to '/Applications/Unity_5.6.0f1'")
          expect(unity).to receive(:root_path=).with('/Applications/Unity_5.6.0f1')
          U3d::MacInstaller.new.sanitize_install(unity)
        end

        it 'dry runs sanitize install' do
          expect(U3d::UI).to receive(:message).with("'/Applications/Unity' would move to '/Applications/Unity_5.6.0f1'")
          U3d::MacInstaller.new.sanitize_install(unity, dry_run: true)
        end

        it 'uninstalls' do
          expect(U3d::UI).to receive(:verbose).with("Uninstalling Unity at '/Applications/Unity'...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "rm -r /Applications/Unity", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully uninstalled '/Applications/Unity'")
          U3d::MacInstaller.new.uninstall(unity: unity)
        end
      end

      context 'when using a custom install with spaces' do
        let(:unity) { macinstall_5_6_custom_with_space }
        it 'sanitizes install' do
          expect(U3d::UI).to receive(:important).with("Moving '/Applications/Unity 5.6.0f1' to '/Applications/Unity_5.6.0f1'...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "mv /Applications/Unity\\ 5.6.0f1 /Applications/Unity_5.6.0f1", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully moved '/Applications/Unity 5.6.0f1' to '/Applications/Unity_5.6.0f1'")
          expect(unity).to receive(:root_path=).with('/Applications/Unity_5.6.0f1')
          U3d::MacInstaller.new.sanitize_install(unity)
        end

        it 'uninstalls' do
          expect(U3d::UI).to receive(:verbose).with("Uninstalling Unity at '/Applications/Unity 5.6.0f1'...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "rm -r /Applications/Unity\\ 5.6.0f1", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully uninstalled '/Applications/Unity 5.6.0f1'")
          U3d::MacInstaller.new.uninstall(unity: unity)
        end
      end
    end

    describe U3d::LinuxInstaller, unless: WINDOWS do
      context 'when using a default install' do
        let(:unity) { linux_5_6_standard }
        it 'aborts sanitize install' do
          expect(U3d::UI).to receive(:verbose).with("move_file does nothing if the path won't change (/opt/unity-editor-5.6.0f1)")
          U3d::LinuxInstaller.new.sanitize_install(unity)
        end

        it 'aborts sanitize install in dry_run as well' do
          expect(U3d::UI).to receive(:verbose).with("move_file does nothing if the path won't change (/opt/unity-editor-5.6.0f1)")
          U3d::LinuxInstaller.new.sanitize_install(unity, dry_run: true)
        end
      end

      context 'when using a weird install' do
        let(:unity) { linux_2017_1_weird }
        it 'sanitizes install' do
          expect(U3d::UI).to receive(:important).with("Moving '/opt/unity-editor-2017.1.0xf3Linux' to '/opt/unity-editor-2017.1.0f3'...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "mv /opt/unity-editor-2017.1.0xf3Linux /opt/unity-editor-2017.1.0f3", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully moved '/opt/unity-editor-2017.1.0xf3Linux' to '/opt/unity-editor-2017.1.0f3'")
          expect(unity).to receive(:root_path=).with('/opt/unity-editor-2017.1.0f3')
          U3d::LinuxInstaller.new.sanitize_install(unity)
        end
      end

      describe '.install' do
        it 'installs a file in standard installation path' do
          filepath = "file.sh"
          allow(File).to receive(:directory?).with(U3d::DEFAULT_LINUX_INSTALL) { true }
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: 'chmod a+x file.sh') {}
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "cd #{U3d::DEFAULT_LINUX_INSTALL}; file.sh", admin: true) {}

          installer = U3d::LinuxInstaller.new
          unity = double("UnityProject")
          allow(installer).to receive(:installed) { [unity] }
          allow(unity).to receive(:version) { '1.2.3f4' }
          expect(installer).to receive(:sanitize_install).with(unity)

          installer.install(filepath, '1.2.3f4', installation_path: nil)
        end
      end

      describe '.list' do
        it 'finds both entries we install and those previously installed using the deb package and doesn\'t sort them' do
          u1 = linux_5_6_standard
          u2 = linux_5_6_debian
          u3 = linux_2017_1_weird
          allow(Dir).to receive(:glob).with('/opt/unity-editor-*/Editor') { ["#{u1.root_path}/Editor", "#{u3.root_path}/Editor"] }
          allow(Dir).to receive(:glob).with('/opt/Unity/Editor') { ["#{u2.root_path}/Editor"] }

          allow(U3d::LinuxInstallation).to receive(:new).with(root_path: u1.root_path) { u1 }
          allow(U3d::LinuxInstallation).to receive(:new).with(root_path: u2.root_path) { u2 }
          allow(U3d::LinuxInstallation).to receive(:new).with(root_path: u3.root_path) { u3 }

          expect(U3d::LinuxInstaller.new.installed).to eql [u1, u3, u2]
        end
      end
    end

    xdescribe U3d::WindowsInstaller do
      context 'when using a default install' do
        let(:unity) { windows_5_6_32bits_default }
        it 'sanitizes install' do
          allow(File).to receive(:expand_path).with(any_args) { unity.path }
          allow(File).to receive(:expand_path).with(any_args) { 'C:/Program Files (x86)' }
          expect(U3d::UI).to receive(:important).with("Moving 'C:\\Program\\ Files\\ \\(x86\\)\\Unity' to 'C:\\Program Files\\Unity_5.6.0f1'...")
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: "move C:\\Program Files (x86)\\Unity C:\\Program Files\\Unity_5.6.0f1", admin: true)
          expect(U3d::UI).to receive(:success).with("Successfully moved 'C:\\Program Files \\(x86\\)\\Unity' to 'C:\\Program Files\\Unity_5.6.0f1'")
          expect(unity).to receive(:root_path=).with('C:\\Program Files\\Unity_5.6.0f1')
          U3d::MacInstaller.new.sanitize_install(unity)
        end

        it 'dry runs sanitize install' do
          allow(File).to receive(:expand_path).with(any_args) { unity.path }
          allow(File).to receive(:expand_path).with(any_args) { 'C:/Program Files (x86)' }
          expect(U3d::UI).to receive(:message).with("'C:\\Program Files (x86)\\Unity' would move to 'C:\\Program Files\\Unity_5.6.0f1'")
          U3d::MacInstaller.new.sanitize_install(unity, dry_run: true)
        end
      end

      context 'when using an already renamed version' do
        let(:unity) { windows_2017_1_64bits_renamed }
        it 'aborts sanitizes install if already renamed' do
          allow(File).to receive(:expand_path).with(any_args) { unity.path }
          allow(File).to receive(:expand_path).with(any_args) { 'C:/Program Files' }
          expect(U3d::UI).to receive(:important).with("sanitize_install does nothing if the path won't change (C:\\Program Files\\Unity_2017.1.0f3)")
          U3d::MacInstaller.new.sanitize_install(unity)
        end
      end
    end
  end
end
