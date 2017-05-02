require 'u3d/cache'
require 'json'
require 'time'

describe U3d do
  describe U3d::Cache do
    describe '#initialize' do
      context 'when there is no cache file' do
        before(:all) do
          @cache_file = "#{ENV['HOME']}/.u3d/cache.json"
        end

        before(:each) do
          File.delete(@cache_file) if File.file?(@cache_file)
        end

        it 'retrieves versions' do
          expect(U3d::UnityVersions).to receive(:list_available)

          U3d::Cache.new
        end

        it 'creates a cache file' do
          allow(U3d::UnityVersions).to receive(:list_available) { { 'test' => 'url' } }

          U3d::Cache.new

          expect(File.file?(@cache_file)).to be true
        end

        it 'writes to the cache file' do
          allow(U3d::UnityVersions).to receive(:list_available)
          file = double('file')

          expect(File).to receive(:open).with(@cache_file, 'w').and_yield(file)
          expect(file).to receive(:write)

          U3d::Cache.new
        end

        it 'stores correct information' do
          allow(U3d::UnityVersions).to receive(:list_available).and_return('test' => 'url')
          U3d::Cache.new

          data = JSON.parse(File.open(@cache_file, 'r').read)
          expect(data['versions'].nil?).to be false
          expect(data['versions']['test']).to eql('url')
        end
      end

      context 'when cache file is outdated' do
        before(:all) do
          @cache_file = "#{ENV['HOME']}/.u3d/cache.json"
          File.delete(@cache_file) if File.file?(@cache_file)
        end

        before(:each) do
          cache = { 'lastupdate' => 0, 'outdatedkey' => 'outdated' }
          File.open(@cache_file, 'w') do |f|
            f.write(cache.to_json)
          end
        end

        after(:each) do
          File.delete(@cache_file) if File.file?(@cache_file)
        end

        it 'checks if the file is up-to-date' do
          file = double('file')
          data = double('data')

          expect(File).to receive(:open).with(@cache_file, 'r') { file }
          expect(file).to receive(:read) { data }
          expect(JSON).to receive(:parse).with(data) { { 'lastupdate' => 0 } }
          expect(Time).to receive(:now) { 60 * 60 * 24 + 1 }
          allow_any_instance_of(U3d::Cache).to receive(:overwrite_cache)

          U3d::Cache.new
        end

        it 'retrieves versions' do
          expect(U3d::UnityVersions).to receive(:list_available)

          U3d::Cache.new
        end

        it 'writes to the cache file' do
          allow(U3d::UnityVersions).to receive(:list_available)
          allow_any_instance_of(U3d::Cache).to receive(:check_for_update).and_return(true)

          file = double('file')

          expect(File).to receive(:open).with(@cache_file, 'w').and_yield(file)
          expect(file).to receive(:write)

          U3d::Cache.new
        end

        it 'stores correct information' do
          allow(U3d::UnityVersions).to receive(:list_available).and_return('test' => 'url')
          U3d::Cache.new

          data = JSON.parse(File.open(@cache_file, 'r').read)
          expect(data['versions'].nil?).to be false
          expect(data['versions']['test']).to eql('url')
        end

        it 'overwrites outdated information' do
          allow(U3d::UnityVersions).to receive(:list_available).and_return('test' => 'url')
          U3d::Cache.new

          data = JSON.parse(File.open(@cache_file, 'r').read)
          expect(data['outdatedkey'].nil?).to be true
        end
      end

      context 'when cache file is fresh' do
        before(:all) do
          @cache_file = "#{ENV['HOME']}/.u3d/cache.json"
          File.delete(@cache_file) if File.file?(@cache_file)
          cache = { 'lastupdate' => Time.now.to_i, 'spec_flag' => true }
          File.open(@cache_file, 'w') do |f|
            f.write(cache.to_json)
          end
          U3d::Cache.new
        end

        after(:each) do
          File.delete(@cache_file) if File.file?(@cache_file)
        end

        it 'does not overwrite cache' do
          allow(U3d::UnityVersions).to receive(:list_available).and_return('test' => 'url')

          expect(File.file?(@cache_file)).to be true
          data = JSON.parse(File.open(@cache_file, 'r').read)
          expect(data['spec_flag'].nil?).to be false
          expect(data['spec_flag']).to be true
        end
      end
    end

    describe '#[]' do
      before(:all) do
        @cache_file = "#{ENV['HOME']}/.u3d/cache.json"
        File.delete(@cache_file) if File.file?(@cache_file)
      end

      after(:each) do
        File.delete(@cache_file) if File.file?(@cache_file)
      end

      it 'returns correct object with a matching key' do
        allow(U3d::UnityVersions).to receive(:list_available).and_return('key' => 'url')
        cache = U3d::Cache.new
        expect(cache['versions']['key']).to eql('url')
      end

      it 'returns nil with wrong key' do
        allow(U3d::UnityVersions).to receive(:list_available).and_return('key' => 'url')
        cache = U3d::Cache.new
        expect(cache['versions']['notakey']).not_to eql('url')
      end
    end
  end
end
