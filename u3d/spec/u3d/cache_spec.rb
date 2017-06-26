require 'u3d/cache'
require 'json'
require 'time'

describe U3d do
  describe U3d::Cache do
    describe '#initialize' do
      context 'when there is no cache file' do
        before(:each) do
          allow(File).to receive(:file?) { false }
        end

        it 'retrieves versions' do
          expect(U3d::UnityVersions).to receive(:list_available)

          U3d::Cache.new
        end

        it 'creates a cache file' do
          allow(U3d::UnityVersions).to receive(:list_available) { { 'test' => 'url' } }
          expect(File).to receive(:open).with(anything, 'w')

          U3d::Cache.new
        end

        it 'writes to the cache file' do
          allow(U3d::UnityVersions).to receive(:list_available)
          file = double('file')

          expect(File).to receive(:open).with(anything, 'w').and_yield(file)
          expect(file).to receive(:write)

          U3d::Cache.new
        end
      end

      context 'when there is a cache file' do
        it 'checks if the file is up-to-date' do
          allow(U3d::UnityVersions).to receive(:list_available) { { 'test' => 'url' } }
          file = double('file')
          cache = '{'\
          '"win":{"lastupdate":0,"versions":{"version": "url"}},'\
          '"mac":{"lastupdate":0,"versions":{"version": "url"}},'\
          '"linux":{"lastupdate":0,"versions":{"version": "url"}}'\
          '}'
          allow(File).to receive(:file?) { true }
          allow(File).to receive(:open).with(anything, 'r').and_yield(file)
          allow(file).to receive(:read) { cache }
          expect(Time).to receive(:now).at_least(:once) { 0 }
          allow(File).to receive(:open).with(anything, 'w')

          U3d::Cache.new
        end

        context 'when cache file is outdated' do
          before(:each) do
            file = double('file')
            cache = '{'\
            '"win":{"lastupdate":0,"versions":{"version": "url"}},'\
            '"mac":{"lastupdate":0,"versions":{"version": "url"}},'\
            '"linux":{"lastupdate":0,"versions":{"version": "url"}}'\
            '}'
            allow(File).to receive(:file?) { true }
            allow(File).to receive(:open).with(anything, 'r').and_yield(file)
            allow(file).to receive(:read) { cache }
            allow(File).to receive(:open).with(anything, 'w')
            allow(File).to receive(:delete)
          end

          it 'retrieves versions' do
            expect(U3d::UnityVersions).to receive(:list_available)

            U3d::Cache.new
          end

          it 'writes to the cache file' do
            allow(U3d::UnityVersions).to receive(:list_available)
            write_file = double('file')

            expect(File).to receive(:open).with(anything, 'w').and_yield(write_file)
            expect(write_file).to receive(:write)

            U3d::Cache.new
          end
        end

        context 'when cache file is fresh' do
          before(:each) do
            file = double('file')
            cache = '{'\
            '"win":{"lastupdate":' + Time.now.to_i.to_s + ',"versions":{"version": "url"}},'\
            '"mac":{"lastupdate":' + Time.now.to_i.to_s + ',"versions":{"version": "url"}},'\
            '"linux":{"lastupdate":' + Time.now.to_i.to_s + ',"versions":{"version": "url"}}'\
            '}'
            allow(File).to receive(:file?) { true }
            allow(File).to receive(:open).with(anything, 'r').and_yield(file)
            allow(file).to receive(:read) { cache }
          end

          it 'does not overwrite cache' do
            expect(File).not_to receive(:open).with(anything, 'w')

            U3d::Cache.new
          end
        end
      end
    end

    describe '#[]' do
      before(:each) do
        allow(U3d::UnityVersions).to receive(:list_available)
        file = double('file')
        cache_data = '{'\
        '"win":{"lastupdate":' + Time.now.to_i.to_s + ',"versions":{"key": "url"}}'\
        '}'
        allow(File).to receive(:file?) { true }
        allow(File).to receive(:open).with(anything, 'r').and_yield(file)
        allow(file).to receive(:read) { cache_data }
      end

      it 'returns correct object with a matching key' do
        cache = U3d::Cache.new
        expect(cache['win']['versions']['key']).to eql('url')
      end

      it 'returns nil with wrong key' do
        cache = U3d::Cache.new
        expect(cache['win']['versions']['notakey']).not_to eql('url')
        expect(cache['win']['versions']['notakey']).to be_nil
      end
    end
  end
end
