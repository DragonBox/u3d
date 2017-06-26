require 'u3d/downloader'

describe U3d do
  describe U3d::Downloader do
    describe U3d::Downloader::MacDownloader do
      describe '.download_all' do
        before(:each) do
          @cache = { 'mac'=> {'version' => 'url'} }
        end

        it 'logs an error when trying to download unknown version' do
          expect(U3d::UI).to receive(:error)
          U3d::Downloader::MacDownloader.download_all('notaversion', @cache)
        end
      end

      describe '.download_specific' do
        before(:each) do
          @cache = { 'mac'=> {'version' => 'url'} }
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
