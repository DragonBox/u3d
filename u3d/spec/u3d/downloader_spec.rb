require 'u3d/downloader'

describe U3d do
  describe U3d::Downloader do
    describe '.download_all' do
      before(:each) do
        @cache = { 'version' => 'url' }
      end

      it 'logs an error when trying to download unknown version' do
        expect(U3d::UI).to receive(:error)
        U3d::Downloader.download_all('notaversion', @cache)
      end
    end

    describe '.download_specific' do
      before(:each) do
        @cache = { 'version' => 'url' }
      end

      it 'logs an error when trying to download unknown version' do
        expect(U3d::UI).to receive(:error)
        U3d::Downloader.download_specific('Unity', 'notaversion', @cache)
      end

      it 'doesn\'t find the package if it does not exist' do
        inif = double('inif')
        allow(U3d::INIparser).to receive(:load_ini).with('version', @cache) { inif }
        allow(inif).to receive(:empty?) { false }
        allow(inif).to receive(:[]).with('notapackage') { {} }

        expect(U3d::UI).to receive(:error)

        U3d::Downloader.download_specific('notapackage', 'version', @cache)
      end
    end
  end
end
