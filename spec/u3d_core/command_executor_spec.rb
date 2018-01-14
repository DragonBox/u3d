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
  end
end
