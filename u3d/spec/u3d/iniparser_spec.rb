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

      it 'raises an error when version is not in cache' do
        expect { U3d::INIparser.load_ini('notakey', @cache) }.to raise_error(ArgumentError)
      end

      context 'when ini file does not exist yet' do
        before(:each) do
          File.delete(@path) if File.file?(@path)
        end

        it 'downloads ini files' do
          file = double('file')
          expect(Net::HTTP).to receive(:get) { 'nothing' }
          allow(IniFile).to receive(:load) { {} }
          allow(File).to receive(:open).and_yield(file)
          allow(file).to receive(:write)

          U3d::INIparser.load_ini(@version, @cache)
        end

        it 'creates the ini file on the filesystem' do
          allow(Net::HTTP).to receive(:get) { 'nothing' }
          allow(IniFile).to receive(:load) { {} }

          U3d::INIparser.load_ini(@version, @cache)

          expect(File.file?(@path)).to be true
        end
      end

      before(:example) do
        File.delete(@path) if File.file?(@path)
      end

      it 'returns correct information' do
        allow(Net::HTTP).to receive(:get) { "[PackageA]\ntitle=packageA\nsize=8\n[PackageB]\ntitle=packageB\n" }

        ini = U3d::INIparser.load_ini(@version, @cache)
        expect(ini['PackageA']['size']).to eq(8)
        expect(ini['PackageB']['title']).to eql('packageB')
      end
    end
  end
end
