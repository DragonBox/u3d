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
  describe U3d::Utils do
    describe '.hashfile' do
      it 'raises an error if the path to the file is not valid' do
        expect { U3d::Utils.hashfile('not_a_dir/not_a_file') }.to raise_error(ArgumentError)
      end

      it 'returns the md5 hash of the file' do
        md5 = double('md5')
        file = double('file')
        allow(File).to receive(:file?)
        expect(File).to receive(:file?).with('path') { true }
        allow(Digest::MD5).to receive(:new) { md5 }
        allow(File).to receive(:open).with('path', 'r').and_yield(file)
        allow(file).to receive(:read)
        allow(file).to receive(:eof?) { true }

        allow(md5).to receive(:hexdigest) { 'hash' }

        expect(U3d::Utils.hashfile('path')).to eql('hash')
      end
    end

    describe '.parse_unity_version' do
      it 'raises an error if the version is not valid' do
        expect { U3d::Utils.parse_unity_version('not_a_version') }.to raise_error(ArgumentError)
      end

      it 'returns the version as an array' do
        expect(U3d::Utils.parse_unity_version('1.2.3f4')).to eql(%w[1 2 3 f 4])
      end
    end
  end
end
