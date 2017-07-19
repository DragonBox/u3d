require 'u3d/utils'

describe U3d do
  describe U3d::UnityVersionNumber do
    describe '#initialize' do
      it 'parses versions' do
        expect(U3d::UnityVersionNumber.new('5.6.0f1').parts).to eq [5,6,0,'f',1]
      end
    end
  end

  describe U3d::UnityVersionComparator do
    describe '#initialize' do
      it 'parses versions' do
        a = [ '5.6.0f1', '4.7.0f1', '5.3.1f1', '5.6.0a4', '5.6.0b7', '5.6.0p2', '5.6.1a4', '5.6.1f3']
        b = a.map{|e| U3d::UnityVersionComparator.new(e)}.sort
        expect(b[0].version.to_s).to eq '4.7.0f1'
        expect(b[1].version.to_s).to eq '5.3.1f1'
        expect(b[2].version.to_s).to eq '5.6.0a4'
        expect(b[3].version.to_s).to eq '5.6.0b7'
        expect(b[4].version.to_s).to eq '5.6.0f1'
        expect(b[5].version.to_s).to eq '5.6.0p2'
        expect(b[6].version.to_s).to eq '5.6.1a4'
        expect(b[7].version.to_s).to eq '5.6.1f3'
      end
    end
  end
end
