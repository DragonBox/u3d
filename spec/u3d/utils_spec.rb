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

      it 'parses MagicLeap versions' do
        expect(U3d::Utils.parse_unity_version('2018.1.9f1-MLTP8.1')).to eql(%w[2018 1 9 f 1])
      end
    end

    describe '.strings' do
      it 'finds printable characters in strings' do
        path = 'spec/data/u3d_console.png'
        expect(U3d::Utils.strings(path).to_a.include?('iTXtXML:com.adobe.xmp')).to be true
      end
    end

    describe '.windows_local_appdata' do
      it 'runs windows_local_appdata without failure on windows', if: WINDOWS do
        if ENV['GITHUB']
          puts `env`
          expected = 'C:/Users/runneradmin/AppData/Local'
          expect(U3d::Utils.windows_local_appdata).to eql(expected)
        else
          puts U3d::Utils.windows_local_appdata
        end
      end

      it 'runs windows_local_appdata fails on non windows', unless: WINDOWS do
        require 'fiddle'
        expect { U3d::Utils.windows_local_appdata }.to raise_error(Fiddle::DLError)
      end
    end

    describe '.windows_fileversion' do
      it 'runs windows_fileversion without failure on widnows', if: WINDOWS do
        data = {
          'spec/assets/exe/Uninstall.exe' => {
            "FileVersion" => "2020.3.1.0",
            "Unity Version" => "2020.3.1f1"
          },
          'spec/assets/exe/UnityBugReporter.exe' => {
            "FileVersion" => "2020.3.1.7841951",
            "Unity Version" => "2020.3.1f1_77a89f25062f"
          }
        }
        data.each do |exe, exe_data|
          path = File.expand_path exe
          exe_data.each do |key, expected_value|
            value = U3d::Utils.windows_fileversion(key, path)
            expect(value).to eql(expected_value)
          end
        end
      end
    end
  end
end
