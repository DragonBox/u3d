# frozen_string_literal: true

## --- BEGIN LICENSE BLOCK ---
# Original work Copyright (c) 2015-present the fastlane authors
# Modified work Copyright 2016-present WeWantToKnow AS
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

require 'support/setups'

describe U3dCore do
  describe U3dCore::CommandExecutor do
    describe "which" do
      require 'tempfile'

      it "does not find commands which are not on the PATH" do
        expect(U3dCore::CommandExecutor.which('not_a_real_command')).to be_nil
      end

      it "finds commands without extensions which are on the PATH", unless: WINDOWS do
        Tempfile.create('foobarbaz') do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f)

          with_env_values('PATH' => temp_dir) do
            expect(U3dCore::CommandExecutor.which(temp_cmd)).to eq(f.path)
          end
        end
      end

      it "finds commands with known extensions which are on the PATH" do
        Tempfile.create(['foobarbaz', '.exe']) do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f, '.exe')

          with_env_values('PATH' => temp_dir, 'PATHEXT' => '.exe') do
            expect(U3dCore::CommandExecutor.which(temp_cmd)).to eq(f.path)
          end
        end
      end

      it "does not find commands with unknown extensions which are on the PATH" do
        Tempfile.create(['foobarbaz', '.exe']) do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f, '.exe')

          with_env_values('PATH' => temp_dir, 'PATHEXT' => '') do
            expect(U3dCore::CommandExecutor.which(temp_cmd)).to be_nil
          end
        end
      end
    end
    describe "execute" do
      it "raise error upon exit status failure", unless: WINDOWS do
        expect do
          U3dCore::CommandExecutor.execute(command: "ruby -e 'exit 1'")
        end.to raise_error(RuntimeError, /Exit status: 1/)
      end

      it "captures error output upon exit status failure", unless: WINDOWS do
        captured_output = []
        error = proc do |l|
          captured_output << l
        end
        output = U3dCore::CommandExecutor.execute(command: "ruby -e 'exit 1'", error: error)
        expect(captured_output).to eq(["Exit status: 1".red])
        expect(output).to eq("Exit status: 1".red)
      end

      it "allows to test I/O buffering", unless: WINDOWS do
        command = "ruby -e '5.times{sleep 0.1; puts \"HI\"}'"
        output = U3dCore::CommandExecutor.execute(command: command, print_all: true)
        expect(output).to eq("HI\nHI\nHI\nHI\nHI")
      end
    end

    describe "has_admin_privileges?" do
      context "on windows" do
        before(:each) do
          allow(U3d::Helper).to receive(:windows?) { true }
        end
      end

      context "outside windows" do
        before(:each) do
          allow(U3d::Helper).to receive(:windows?) { false }
        end

        def expect_recurse(retry_count, system_result)
          credentials = double("Credentials")
          expect(U3dCore::CommandExecutor).to receive(:has_admin_privileges?).with(retry_count: retry_count).once.ordered.and_call_original
          expect(U3dCore::Credentials).to receive(:new).once.ordered { credentials }
          expect(credentials).to receive(:password).once.ordered { "***" }
          expect(U3dCore::CommandExecutor).to receive(:system_no_output).once.ordered.with(/sudo/) { system_result }
          expect(credentials).to receive(:forget_credentials).once.ordered unless system_result
        end

        it "retries until its specified retry_count" do
          expect_recurse(2, false)
          expect_recurse(1, false)
          expect_recurse(0, false)

          r = U3dCore::CommandExecutor.has_admin_privileges?(retry_count: 2)
          expect(r).to be false
        end

        it "doesn't retry with a 0 retry_count" do
          expect_recurse(0, false)

          r = U3dCore::CommandExecutor.has_admin_privileges?(retry_count: 0)
          expect(r).to be false
        end

        it "stops retrying when it gets the right password" do
          expect_recurse(2, false)
          expect_recurse(1, true)

          r = U3dCore::CommandExecutor.has_admin_privileges?(retry_count: 2)
          expect(r).to be true
        end

        it "doesn't ask for password when user is root" do
          with_env_values('USER' => 'root') do
            expect(U3dCore::CommandExecutor.has_admin_privileges?).to be true
          end
        end

        it "doesn't wrap a command when user is root" do
          with_env_values('USER' => 'root') do
            expect(U3dCore::CommandExecutor.grant_admin_privileges('pwd')).to eq 'pwd'
          end
        end

        it "asks for password when user is not root" do
          credentials = double("Credentials")
          expect(U3dCore::Credentials).to receive(:new).once.ordered { credentials }
          expect(credentials).to receive(:password).once.ordered { 'abc' }
          expect(U3dCore::CommandExecutor).to receive(:system_no_output).once.ordered.and_return(false)
          expect(credentials).to receive(:forget_credentials).once.ordered {}
          with_env_values('USER' => 'not root') do
            expect(U3dCore::CommandExecutor.has_admin_privileges?(retry_count: 0)).to be false
          end
        end

        it "wraps a command when user is not root" do
          allow(U3dCore::CommandExecutor).to receive(:has_admin_privileges?).and_return(true)
          credentials = double("Credentials")
          expect(U3dCore::Credentials).to receive(:new).once.ordered { credentials }
          expect(credentials).to receive(:password).once.ordered { 'abc' }
          with_env_values('USER' => 'not root') do
            expect(U3dCore::CommandExecutor.grant_admin_privileges('pwd')).to eq 'sudo -k && echo abc | sudo -S bash -c "pwd"'
          end
        end
      end
    end
  end
end
