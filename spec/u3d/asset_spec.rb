# frozen_string_literal: true

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

require 'u3d/asset'
require 'yaml'

def mock_file(path, guid, extra_lines = [])
  allow(File).to receive(:exist?).with(path) { true }
  allow(File).to receive(:file?).with(path) { true }
  allow(File).to receive(:read).with("#{path}.meta") { (["guid: #{guid}"] | extra_lines).join("\n") }
end

describe U3d do
  describe U3d::Asset do
    before(:each) do
      # The following lines are necessary or raises rspec errors
      # See https://github.com/chefspec/chefspec/issues/766
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:file?).and_call_original
      allow(File).to receive(:read).and_call_original
    end

    describe '#initialize' do
      context 'when the asset file does not exist' do
        it 'fails when passed a file that does not exist' do
          @file = '/some/path.file'
          expect(File).to receive(:exist?).with(@file) { false }

          expect { U3d::Asset.new(@file) }.to raise_error(ArgumentError)
        end
      end

      context 'when the asset file exists' do
        before(:each) do
          @file = '/some/path.file'
          @guid = 'abc123456'
          mock_file(@file, @guid)

          @asset = U3d::Asset.new(@file)
        end

        it 'has the correct path' do
          expect(@asset.path).to eql(@file)
        end

        it 'has the correct path to the .meta' do
          expect(@asset.meta_path).to eql("#{@file}.meta")
        end

        it 'successfully retrieves the guid' do
          expect(@asset.guid).to eql(@guid)
        end

        it 'stores the parsed meta' do
          expect(@asset.meta).not_to be_empty
          expect(@asset.meta).to have_key('guid')
        end
      end
    end

    describe '#guid_references' do
      it 'retrieves files referencing this asset by guid' do
        @file = '/some/path.file'
        @guid = 'abc123456'
        mock_file(@file, @guid)

        @asset = U3d::Asset.new(@file)

        @reference_a = '/some/reference.A'
        @guid_reference_a = 'A'
        @reference_b = '/some/reference.B'
        @guid_reference_b = 'B'

        mock_file(@reference_a, @guid_reference_a, ["references_sript: #{@guid}"])
        mock_file(@reference_b, @guid_reference_b, ["references_sript: #{@guid}"])

        allow(U3dCore::CommandExecutor).to receive(:execute) { [@reference_a, @reference_b].join("\n") }

        expect(@asset.guid_references).to satisfy do |list|
          list.count == 2 &&
            list.any? { |f| f.path == @reference_a && f.guid == @guid_reference_a } &&
            list.any? { |f| f.path == @reference_b && f.guid == @guid_reference_b }
        end
      end
    end

    describe '#name_references' do
      it 'retrieves files referencing this asset by name' do
        @file = '/some/path.file'
        @guid = 'abc123456'
        mock_file(@file, @guid)

        @asset = U3d::Asset.new(@file)

        @reference_a = '/some/reference.A'
        @guid_reference_a = 'A'
        @reference_b = '/some/reference.B'
        @guid_reference_b = 'B'

        mock_file(@reference_a, @guid_reference_a, ["references_sript: #{@guid}"])
        mock_file(@reference_b, @guid_reference_b, ["references_sript: #{@guid}"])

        allow(U3dCore::CommandExecutor).to receive(:execute) { [@reference_a, @reference_b].join("\n") }

        expect(@asset.guid_references).to satisfy do |list|
          list.count == 2 &&
            list.any? { |f| f.path == @reference_a && f.guid == @guid_reference_a } &&
            list.any? { |f| f.path == @reference_b && f.guid == @guid_reference_b }
        end
      end
    end

    describe '#extension' do
      it 'gets the correct extension of the asset' do
        @file = '/some/path.file'
        @guid = 'abc123456'
        mock_file(@file, @guid)

        @asset = U3d::Asset.new(@file)

        expect(@asset.extension).to eql('.file')
      end
    end

    describe '#to_s' do
      it 'concatenates the guid and the name of the asset' do
        @file = '/some/path.file'
        @guid = 'abc123456'
        mock_file(@file, @guid)

        @asset = U3d::Asset.new(@file)

        expect(@asset.to_s).to eql([@guid, @file].join(':'))
      end
    end

    describe '#inspect' do
      it 'concatenates the guid and the name of the asset' do
        @file = '/some/path.file'
        @guid = 'abc123456'
        mock_file(@file, @guid)

        @asset = U3d::Asset.new(@file)

        expect(@asset.inspect).to eql([@guid, @file].join(':'))
      end
    end

    describe ':glob' do
      it 'retrieves all assets matching a path pattern' do
        @file_a = '/some/pathA.file'
        @guid_a = 'abc123456A'
        @file_b = '/some/pathB.file'
        @guid_b = 'abc123456B'
        mock_file(@file_a, @guid_a)
        mock_file(@file_b, @guid_b)

        @pattern = '/some/path_*'
        expect(Dir).to receive(:glob).with(@pattern) { [@file_a, @file_b] }

        expect(U3d::Asset.glob(@pattern)).to satisfy do |list|
          list.count == 2 &&
            list.any? { |f| f.path == @file_a && f.guid == @guid_a } &&
            list.any? { |f| f.path == @file_b && f.guid == @guid_b }
        end
      end

      it 'ignores .meta files' do
        @file = '/some/path.file'
        @guid = 'abc123456'
        mock_file(@file, @guid)

        @pattern = '/some/path_*'
        expect(Dir).to receive(:glob).with(@pattern) { [@file, '/some/path_other.meta'] }

        expect(U3d::Asset.glob(@pattern).count).to eql(1)
      end
    end
  end
end
