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

require 'u3d/iniparser'
require 'net/http'

describe U3d do
  describe U3d::INIparser do
    describe '.load_ini' do
      before(:each) do
        @version = 'key'
        @cache = { @version => 'url' }
        name = 'unity-%s-osx.ini' % @version
        @path = File.expand_path(name, "#{ENV['HOME']}/.u3d/ini_files")
      end

      it 'raises an error when trying to load INI files for OS different from Mac or Windows' do
        expect { U3d::INIparser.load_ini('key', @cache, os: :linux) }.to raise_error(ArgumentError)
      end

      context 'when offline' do
        it 'raises an error when trying to load INI files absent from filesystem' do
          allow(File).to receive(:file?) { false }
          expect { U3d::INIparser.load_ini('key', @cache, offline: true) }.to raise_error(RuntimeError)
        end

        it 'parses and loads the INI data already existing' do
          Tempfile.create(['temp', '.ini']) do |f|
            ini_string = "[A]\ntest=initesting\n[B]\ntest=secondsection"
            f.write(ini_string)
            f.rewind
            allow(File).to receive(:file?) { true }
            allow(IniFile).to receive(:load).and_wrap_original { |m, _args| m.call(f.path) }
            data = U3d::INIparser.load_ini('key', @cache, offline: true)
            expect(data['A']).not_to be_nil
            expect(data['A']['test']).to eql('initesting')
          end
        end
      end

      context 'when online' do
        it 'gets the INI file from the web if it is absent' do
          file = double('file')
          allow(File).to receive(:file?) { false }
          allow(IniFile).to receive(:load)
          expect(Net::HTTP).to receive(:get) { '' }
          U3d::INIparser.load_ini('key', @cache, offline: false)
        end

        it 'parses and loads the INI data already existing without download' do
          Tempfile.create(['temp', '.ini']) do |f|
            ini_string = "[A]\ntest=initesting\n[B]\ntest=secondsection"
            f.write(ini_string)
            f.rewind
            allow(File).to receive(:file?) { true }
            allow(IniFile).to receive(:load).and_wrap_original { |m, _args| m.call(f.path) }
            expect(Net::HTTP).not_to receive(:get)
            data = U3d::INIparser.load_ini('key', @cache, offline: false)
            expect(data['A']).not_to be_nil
            expect(data['A']['test']).to eql('initesting')
          end
        end
      end
    end
  end
end
