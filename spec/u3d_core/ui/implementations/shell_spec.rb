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

describe U3dCore do
  describe U3dCore::Shell do
    describe "#format_string" do
      let(:shell) { U3dCore::Shell.new }
      let(:atime) { Time.new(2017, 07, 20, 12, 21, 35) }

      describe "with log timestamp off" do
        it "does add a default timestamp prefix" do
          U3dCore::Globals.with_log_timestamps(false) do
            expect(shell.format_string(atime, "")).to eq("")
          end
        end

        it "doesn't show severity by default" do
          U3dCore::Globals.with_log_timestamps(false) do
            expect(shell.format_string(atime, "INFO")).to eq("")
          end
        end

        it "shows severity and a no timestamp in verbose mode" do
          U3dCore::Globals.with_log_timestamps(false) do
            U3dCore::Globals.with_verbose(true) do
              expect(shell.format_string(atime, "INFO")).to eq("INFO ")
            end
          end
        end
      end

      describe "with log timestamp on" do
        it "does add a default timestamp prefix" do
          U3dCore::Globals.with_log_timestamps(true) do
            expect(shell.format_string(atime, "")).to eq("[12:21:35] ")
          end
        end

        it "doesn't show severity by default" do
          U3dCore::Globals.with_log_timestamps(true) do
            expect(shell.format_string(atime, "INFO")).to eq("[12:21:35] ")
          end
        end

        it "shows severity and a longer timestamp in verbose mode" do
          U3dCore::Globals.with_log_timestamps(true) do
            U3dCore::Globals.with_verbose(true) do
              expect(shell.format_string(atime, "INFO")).to eq("INFO [2017-07-20 12:21:35.00] ")
            end
          end
        end

        it "overrides the timestamp from the ENV" do
          U3dCore::Globals.with_log_timestamps(true) do
            with_env_values('U3D_UI_TIMESTAMP' => '%H:%M') do
              expect(shell.format_string(atime, "")).to eq("[12:21] ")
            end
          end
        end

        it "overries the timestamp from the ENV, with HIDE having the last word" do
          U3dCore::Globals.with_log_timestamps(true) do
            with_env_values('U3D_UI_TIMESTAMP' => '%H:%M', 'U3D_HIDE_TIMESTAMP' => '') do
              expect(shell.format_string(atime, "")).to eq("")
            end
          end
        end
      end
    end
  end
end
