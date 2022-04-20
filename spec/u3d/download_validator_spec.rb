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

require 'u3d/downloader'
require 'u3d/download_validator'
require 'u3d/unity_module'
require 'u3d/unity_version_definition'
require 'support/setups'

describe U3d do
  describe U3d::DownloadValidator do
    describe '.hash_validation' do
      before(:all) do
        @validator = U3d::DownloadValidator.new
      end

      context 'when both hashes match' do
        it 'returns true' do
          result = @validator.hash_validation(expected: 'somehash', actual: 'somehash')
          expect(result).to be true
        end
      end

      context 'when no expected hash is given' do
        it 'returns true' do
          result = @validator.hash_validation(expected: nil, actual: 'somehash')
          expect(result).to be true
        end

        it 'logs a verbose message' do
          expect(U3dCore::UI).to receive(:verbose).with(/[Nn]o.*hash.*validation/)
          @validator.hash_validation(expected: nil, actual: 'somehash')
        end
      end

      context 'when hashes do not match' do
        it 'returns false' do
          result = @validator.hash_validation(expected: 'somehash', actual: 'anotherhash')
          expect(result).to be false
        end

        it 'logs an important message' do
          expect(U3dCore::UI).to receive(:important).with(/[Ww]rong.*hash/)
          @validator.hash_validation(expected: 'somehash', actual: 'anotherhash')
        end
      end
    end

    describe '.size_validation' do
      before(:all) do
        @validator = U3d::DownloadValidator.new
      end

      context 'when both sizes match' do
        it 'returns true' do
          result = @validator.size_validation(expected: 123_456, actual: 123_456)
          expect(result).to be true
        end
      end

      context 'when no expected size is given' do
        it 'returns true' do
          result = @validator.size_validation(expected: nil, actual: 123_456)
          expect(result).to be true
        end

        it 'logs a verbose message' do
          expect(U3dCore::UI).to receive(:verbose).with(/[Nn]o.*size.*validation/)
          @validator.size_validation(expected: nil, actual: 123_456)
        end
      end

      context 'when sizes do not match' do
        it 'returns false' do
          result = @validator.size_validation(expected: 123_456, actual: 654_321)
          expect(result).to be false
        end

        it 'logs an important message' do
          expect(U3dCore::UI).to receive(:important).with(/[Ww]rong.*size/)
          @validator.size_validation(expected: 123_456, actual: 654_321)
        end
      end
    end

    describe U3d::LinuxValidator do
      describe '.validate' do
        before(:all) do
          @validator = U3d::LinuxValidator.new
        end

        context 'when no ini file is present' do
          it 'returns true' do
            definition = mock_version_definition(packages: [])
            result = @validator.validate('somepackage', 'somefile', definition)
            expect(result).to be true
          end

          it 'logs an important message' do
            definition = mock_version_definition(packages: [])
            expect(U3dCore::UI).to receive(:important).with(/assum.*correct/)
            @validator.validate('somepackage', 'somefile', definition)
          end
        end

        context 'when an ini file is present' do
          before(:all) do
            @package = U3d::UnityModule.new(id: 'somepackage', download_size: 123_456)
          end

          it 'reads the size of the file' do
            definition = mock_version_definition(packages: [@package])
            expect(File).to receive(:size).with('somefile') { 123_456 }
            @validator.validate(@package.id, 'somefile', definition)
          end

          context 'when the sizes match' do
            it 'returns true' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { true }
              allow(File).to receive(:size) { 123_456 }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be true
            end
          end

          context 'when the sizes do not match' do
            it 'returns false' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { false }
              allow(File).to receive(:size) { 123_456 }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be false
            end
          end
        end
      end
    end

    describe U3d::MacValidator do
      describe '.validate' do
        before(:all) do
          @validator = U3d::MacValidator.new
        end

        context 'when the ini file does not contain md5 (package is external)' do
          before(:all) do
            @package = U3d::UnityModule.new(id: 'somepackage', download_size: 123_456, checksum: nil)
          end

          it 'skips validation' do
            definition = mock_version_definition(packages: [@package])
            expect(@validator).to_not receive(:size_validation)
            expect(@validator).to_not receive(:hash_validation)

            @validator.validate(@package.id, 'somefile', definition)
          end

          it 'returns true' do
            definition = mock_version_definition(packages: [@package])
            result = @validator.validate(@package.id, 'somefile', definition)
            expect(result).to be true
          end

          it 'logs a verbose message' do
            definition = mock_version_definition(packages: [@package])
            expect(U3dCore::UI).to receive(:verbose).with(/[Vv]alidation.*skip/)
            @validator.validate(@package.id, 'somefile', definition)
          end
        end

        context 'when there is an ini file' do
          before(:all) do
            @package = U3d::UnityModule.new(id: 'somepackage', download_size: 123_456, checksum: 'somehash')
          end

          context 'when sizes do not match' do
            it 'returns false' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { false }
              allow(@validator).to receive(:hash_validation) { true }
              allow(File).to receive(:size) { 123_456 }
              allow(U3d::Utils).to receive(:hashfile) { 'somehash' }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be false
            end
          end

          context 'when hashes do not match' do
            it 'returns false' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { true }
              allow(@validator).to receive(:hash_validation) { false }
              allow(File).to receive(:size) { 123_456 }
              allow(U3d::Utils).to receive(:hashfile) { 'somehash' }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be false
            end
          end

          context 'when hashes and sizes match' do
            it 'returns true' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { true }
              allow(@validator).to receive(:hash_validation) { true }
              allow(File).to receive(:size) { 123_456 }
              allow(U3d::Utils).to receive(:hashfile) { 'somehash' }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be true
            end
          end
        end
      end
    end

    describe U3d::WindowsValidator do
      describe '.validate' do
        before(:all) do
          @validator = U3d::WindowsValidator.new
        end

        context 'when the ini file does not contain md5 (package is external)' do
          before(:all) do
            @package = U3d::UnityModule.new(id: 'somepackage', download_size: 123_456, checksum: nil)
          end

          it 'skips validation' do
            definition = mock_version_definition(packages: [@package])
            expect(@validator).to_not receive(:size_validation)
            expect(@validator).to_not receive(:hash_validation)

            @validator.validate(@package.id, 'somefile', definition)
          end

          it 'returns true' do
            definition = mock_version_definition(packages: [@package])
            result = @validator.validate(@package.id, 'somefile', definition)
            expect(result).to be true
          end

          it 'logs a verbose message' do
            definition = mock_version_definition(packages: [@package])
            expect(U3dCore::UI).to receive(:verbose).with(/[Vv]alidation.*skip/)
            @validator.validate(@package.id, 'somefile', definition)
          end
        end

        context 'when there is an ini file' do
          before(:all) do
            @package = U3d::UnityModule.new(id: 'somepackage', download_size: 123_456, checksum: 'somehash')
          end

          context 'when sizes do not match' do
            it 'returns false' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { false }
              allow(@validator).to receive(:hash_validation) { true }
              allow(File).to receive(:size) { 123_456 }
              allow(U3d::Utils).to receive(:hashfile) { 'somehash' }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be false
            end
          end

          context 'when hashes do not match' do
            it 'returns false' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { true }
              allow(@validator).to receive(:hash_validation) { false }
              allow(File).to receive(:size) { 123_456 }
              allow(U3d::Utils).to receive(:hashfile) { 'somehash' }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be false
            end
          end

          context 'when hashes and sizes match' do
            it 'returns true' do
              definition = mock_version_definition(packages: [@package])
              allow(@validator).to receive(:size_validation) { true }
              allow(@validator).to receive(:hash_validation) { true }
              allow(File).to receive(:size) { 123_456 }
              allow(U3d::Utils).to receive(:hashfile) { 'somehash' }
              result = @validator.validate(@package.id, 'somefile', definition)
              expect(result).to be true
            end
          end
        end
      end
    end
  end
end
