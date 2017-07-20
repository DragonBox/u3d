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

require 'u3d/utils'

describe U3d do
  describe U3d::UnityVersionNumber do
    describe '#initialize' do
      it 'parses versions' do
        expect(U3d::UnityVersionNumber.new('5.6.0f1').parts).to eq [5,6,0,'f',1]
      end
    end
  end

  describe U3d::UnityVersionComparator do
    describe '#initialize' do
      it 'parses versions' do
        a = [ '5.6.0f1', '4.7.0f1', '5.3.1f1', '5.6.0a4', '5.6.0b7', '5.6.0p2', '5.6.1a4', '5.6.1f3']
        b = a.map{|e| U3d::UnityVersionComparator.new(e)}.sort
        expect(b[0].version.to_s).to eq '4.7.0f1'
        expect(b[1].version.to_s).to eq '5.3.1f1'
        expect(b[2].version.to_s).to eq '5.6.0a4'
        expect(b[3].version.to_s).to eq '5.6.0b7'
        expect(b[4].version.to_s).to eq '5.6.0f1'
        expect(b[5].version.to_s).to eq '5.6.0p2'
        expect(b[6].version.to_s).to eq '5.6.1a4'
        expect(b[7].version.to_s).to eq '5.6.1f3'
      end
    end
  end
end
