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

require 'u3d/downloader'

describe U3d do
  describe U3d::Downloader do
    describe U3d::Downloader::MacDownloader do
      describe '.download_all' do
        before(:each) do
          @cache = { 'mac' => { 'version' => 'url' } }
        end

        it 'logs an error when trying to download unknown version' do
          expect(U3d::UI).to receive(:error)
          U3d::Downloader::MacDownloader.download_all('notaversion', @cache)
        end
      end

      describe '.download_specific' do
        before(:each) do
          @cache = { 'mac' => { 'version' => 'url' } }
        end

        it 'logs an error when trying to download unknown version' do
          expect(U3d::UI).to receive(:error)
          U3d::Downloader::MacDownloader.download_specific('Unity', 'notaversion', @cache)
        end

        it 'doesn\'t find the package if it does not exist' do
          inif = double('inif')
          allow(U3d::INIparser).to receive(:load_ini).with('version', @cache) { inif }
          allow(inif).to receive(:empty?) { false }
          allow(inif).to receive(:[]).with('notapackage') { {} }

          expect(U3d::UI).to receive(:error)

          U3d::Downloader::MacDownloader.download_specific('notapackage', 'version', @cache)
        end
      end
    end

    describe U3d::Downloader::WindowsDownloader do
      describe '.download_all' do
        before(:each) do
          @cache = { 'version' => 'url' }
        end

        it 'logs an error when trying to download unknown version' do
          expect(U3d::UI).to receive(:error)
          U3d::Downloader::WindowsDownloader.download_all('notaversion', @cache)
        end
      end

      describe '.download_specific' do
        before(:each) do
          @cache = { 'version' => 'url' }
        end

        it 'logs an error when trying to download unknown version' do
          expect(U3d::UI).to receive(:error)
          U3d::Downloader::WindowsDownloader.download_specific('Unity', 'notaversion', @cache)
        end

        it 'doesn\'t find the package if it does not exist' do
          inif = double('inif')
          allow(U3d::INIparser).to receive(:load_ini).with('version', @cache) { inif }
          allow(inif).to receive(:empty?) { false }
          allow(inif).to receive(:[]).with('notapackage') { {} }

          expect(U3d::UI).to receive(:error)

          U3d::Downloader::WindowsDownloader.download_specific('notapackage', 'version', @cache)
        end
      end
    end

    describe U3d::Downloader::LinuxDownloader do
      describe '.download' do
        before(:each) do
          @cache = { 'version' => 'url' }
        end

        it 'logs an error when trying to download unknown version' do
          expect(U3d::UI).to receive(:error)
          U3d::Downloader::LinuxDownloader.download('notaversion', @cache)
        end
      end
    end
  end
end
