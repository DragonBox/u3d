require 'u3d/utils'

describe U3d do
  describe U3d::Utils do
    describe '.hashfile' do
      it 'raises an error if the path to the file is not valid' do
        expect{ U3d::Utils.hashfile('not_a_dir/not_a_file') }.to raise_error
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
        expect{ U3d::Utils.parse_unity_version('not_a_version') }.to raise_error
      end

      it 'returns the version as an array' do
        expect(U3d::Utils.parse_unity_version('1.2.3f4')).to eql(['1', '2', '3', 'f', '4'])
      end
    end
  end
end
