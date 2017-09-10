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

require 'u3d_core/core_ext/string'

describe String do
  describe ".argescape" do
    context "on windows" do
      before(:each) do
        allow(U3d::Helper).to receive(:windows?) { true }
      end
      it "doesn't quote arguments without spaces" do
        puts "apath".argescape
        expect("apath".argescape).to eq("apath")
      end
      it "quotes arguments with spaces" do
        expect("a path".argescape).to eq("\"a path\"")
      end
    end
    context "oustide windows" do
      before(:each) do
        allow(U3d::Helper).to receive(:windows?) { false }
      end
      it "doesn't quote arguments without spaces" do
        expect("apath".argescape).to eq("apath")
      end
      it "escapes arguments with spaces" do
        expect("a path".argescape).to eq("a\\ path")
      end
    end
  end
end
