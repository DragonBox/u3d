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

require 'u3d/cache'
require 'json'
require 'time'

describe U3d do
  describe U3d::Cache do
    describe '#initialize' do
      context 'invalid args' do
        it 'fails if offline and force_refresh are set' do
          expect do
            U3d::Cache.new(force_refresh: true, offline: true)
          end.to raise_error(RuntimeError, /Cache: cannot specify both offline and force_refresh/)
        end
      end
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
      context 'when there is no cache file' do
        before(:each) do
          allow(File).to receive(:file?) { false }
        end

        let(:cache) { U3d::Cache.new(offline: true) }

        it 'retrieves versions' do
          expect(cache["win"]).to eq(nil)
        end
      end

      context 'when there is a cache file' do
        before(:each) do
          allow(U3d::UnityVersions).to receive(:list_available)
          file = double('file')
          cache_data = '{'\
          '"win":{"lastupdate":' + Time.now.to_i.to_s + ',"versions":{"key": "url"}},'\
          '"mac":{"lastupdate":' + Time.now.to_i.to_s + ',"versions":{"key": "url"}},'\
          '"linux":{"lastupdate":' + Time.now.to_i.to_s + ',"versions":{"key": "url"}}'\
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
end
