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
require 'support/setups'

describe U3d do
  describe U3d::INIparser do
    describe '.load_ini' do
      before(:each) do
        @version = 'key'
        @cache = { @version => 'url' }
      end

      context 'when offline' do
        # this to ensure tests are not failing on Linux platform
        let(:platform_os) { :mac }

        it 'raises an error when trying to load INI files absent from filesystem' do
          allow(File).to receive(:file?) { false }
          expect { U3d::INIparser.load_ini('key', @cache, os: platform_os, offline: true) }.to raise_error(RuntimeError)
        end

        it 'parses and loads the INI data already existing' do
          Tempfile.create(['temp', '.ini']) do |f|
            ini_string = "[A]\ntest=initesting\n[B]\ntest=secondsection"
            f.write(ini_string)
            f.rewind
            allow(File).to receive(:file?) { true }
            allow(File).to receive(:size) { ini_string.length }
            allow(IniFile).to receive(:load).and_wrap_original { |m, _args| m.call(f.path) }
            data = U3d::INIparser.load_ini('key', @cache, os: platform_os, offline: true)
            expect(data['A']).not_to be_nil
            expect(data['A']['test']).to eql('initesting')
          end
        end

        it 'loads and filters broken Linux INI' do
          broken_ini = 'spec/fixtures/unity-2017.3.0f1-linux.ini'
          allow(File).to receive(:file?) { true }
          allow(File).to receive(:size) { 1 }
          allow(IniFile).to receive(:load).and_wrap_original { |m, _args| m.call(broken_ini) }

          data = U3d::INIparser.load_ini('key', @cache, os: :linux, offline: true)
          expect(data.keys).to eq %w[Unity Documentation StandardAssets Example Android iOS Mac WebGL Windows Facebook-Games]
        end
      end

      context 'when online' do
        # this to ensure tests are not failing on Linux platform
        let(:platform_os) { :mac }

        it 'gets the INI file from the web if it is absent' do
          allow(File).to receive(:file?) { false }
          allow(IniFile).to receive(:load)
          expect(Net::HTTP).to receive(:get) { '' }
          U3d::INIparser.load_ini('key', @cache, os: platform_os, offline: false)
        end

        it 'doesn\'t write the INI file from the web if it fails to download it' do
          allow(File).to receive(:file?) { false }
          allow(Net::HTTP).to receive(:get).with(anything).and_raise("network error")
          expect(File).not_to receive(:open)
          expect(IniFile).not_to receive(:load)
          expect do
            U3d::INIparser.load_ini('key', @cache, os: platform_os, offline: false)
          end.to raise_error("network error")
        end

        it 'gets the INI file from the web if it is empty' do
          allow(File).to receive(:file?) { true }
          allow(File).to receive(:size) { 0 }
          allow(IniFile).to receive(:load)
          expect(Net::HTTP).to receive(:get) { '' }
          U3d::INIparser.load_ini('key', @cache, os: platform_os, offline: false)
        end

        it 'parses and loads the INI data already existing without download' do
          Tempfile.create(['temp', '.ini']) do |f|
            ini_string = "[A]\ntest=initesting\n[B]\ntest=secondsection"
            f.write(ini_string)
            f.rewind
            allow(File).to receive(:file?) { true }
            allow(File).to receive(:size) { 1 }
            allow(IniFile).to receive(:load).and_wrap_original { |m, _args| m.call(f.path) }
            expect(Net::HTTP).not_to receive(:get)
            data = U3d::INIparser.load_ini('key', @cache, os: platform_os, offline: false)
            expect(data['A']).not_to be_nil
            expect(data['A']['test']).to eql('initesting')
          end
        end

        it 'fakes the INI file for standalone versions of Linux' do
          version = 'key'
          installer_url = 'url/unity-editor-installer-2017.1.1f1.sh'
          size = 1034
          cache = { version => installer_url }

          allow(File).to receive(:file?) { false }
          allow(IniFile).to receive(:load)
          expect(U3d::Utils).to receive(:get_url_content_length).with(installer_url) { size }
          expect(U3d::INIparser).to receive(:create_linux_ini).with(version, size, installer_url)

          U3d::INIparser.load_ini(version, cache, os: :linux, offline: false)
        end
      end
    end

    describe '.create_linux_ini' do
      context 'existing ini file' do
        it 'does not rewrite the file' do
          path = %r{\/.u3d\/ini_files\/unity-1.2.3f4-linux.ini}

          on_linux

          allow(File).to receive(:file?).with(path) { true }
          allow(File).to receive(:size) { 1 }
          expect(File).to_not receive(:open)

          U3d::INIparser.create_linux_ini('1.2.3f4', 12_345, 'http://example.com/')
        end
      end

      context 'non existing ini file' do
        it 'writes the file' do
          path = %r{Library\/Application Support\/u3d\/ini_files\/unity-1.2.3f4-linux.ini}

          on_mac

          allow(File).to receive(:file?).with(path) { false }
          file = double('file')
          allow(File).to receive(:open).with(path, 'wb').and_yield file

          expect(file).to receive(:write).with(%r{\[Unity\](.*\n)+title=Unity\nsize=12345\nurl=http:\/\/example.com})

          U3d::INIparser.create_linux_ini('1.2.3f4', 12_345, 'http://example.com/')
        end
      end

      context 'empty ini file' do
        it 'writes the file' do
          path = %r{Library\/Application Support\/u3d\/ini_files\/unity-1.2.3f4-linux.ini}

          on_mac

          allow(File).to receive(:file?).with(path) { true }
          allow(File).to receive(:size) { 0 }
          file = double('file')
          allow(File).to receive(:open).with(path, 'wb').and_yield file

          expect(file).to receive(:write).with(%r{\[Unity\](.*\n)+title=Unity\nsize=12345\nurl=http:\/\/example.com})

          U3d::INIparser.create_linux_ini('1.2.3f4', 12_345, 'http://example.com/')
        end
      end
    end
  end
end
