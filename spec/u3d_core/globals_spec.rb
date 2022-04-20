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

require 'u3d_core/globals'

describe U3dCore do
  describe U3dCore::Globals do
    # [:verbose, :log_timestamps, :use_keychain, :do_not_login].each do |global|
    describe '#verbose?' do
      it 'defaults to nil' do
        expect(U3dCore::Globals.verbose?).to eq(nil)
      end

      it 'can be set to false' do
        U3dCore::Globals.with_verbose(false) do
          expect(U3dCore::Globals.verbose?).to eq(false)
        end
      end

      it 'can be set to true' do
        U3dCore::Globals.with_verbose(true) do
          expect(U3dCore::Globals.verbose?).to eq(true)
        end
      end
    end

    describe "With non existing properties" do
      it 'doesn\'t find with_XXXX methods' do
        expect { U3dCore::Globals.with_XXXXX(true) }.to raise_error(NoMethodError)
      end

      it 'doesn\'t find XXXX? methods' do
        expect { U3dCore::Globals.XXXXX? }.to raise_error(NoMethodError)
      end

      it 'doesn\'t find the property' do
        expect { U3dCore::Globals.XXXXX }.to raise_error(NoMethodError)
      end
    end

    describe "respond_to" do
      describe "With existing properties" do
        it 'responds to with_XXXX methods' do
          expect { U3dCore::Globals.respond_to?(:with_verbose).to be(true) }
        end
        it 'responds to XXXX? methods' do
          expect { U3dCore::Globals.respond_to?(:verbose?).to be(true) }
        end

        it 'responds to the property' do
          expect { U3dCore::Globals.respond_to?(:verbose).to be(true) }
        end
      end

      describe "With non existing properties" do
        it 'doesn\'t respond to with_XXXX methods' do
          expect { U3dCore::Globals.respond_to?(:with_XXXX).to be(false) }
        end
        it 'doesn\'t respond to XXXX? methods' do
          expect { U3dCore::Globals.respond_to?(:XXXX?).to be(false) }
        end

        it 'doesn\'t respond to the property' do
          expect { U3dCore::Globals.respond_to?(:XXXX).to be(false) }
        end
      end
    end

    describe "respond_to_missing" do
      describe "With existing properties" do
        it 'responds to with_XXXX methods' do
          expect { U3dCore::Globals.method(:with_verbose).name.to eq('with_verbose') }
        end
        it 'responds to XXXX? methods' do
          expect { U3dCore::Globals.method(:verbose?).name.to eq('with_verbose') }
        end

        it 'responds to the property' do
          expect { U3dCore::Globals.method(:verbose).call.to eq(false) }
        end
      end

      describe "With non existing properties" do
        it 'doesn\'t respond to with_XXXX methods' do
          expect { U3dCore::Globals.method(:with_XXXX) }.to raise_error(NameError)
        end
        it 'doesn\'t respond to XXXX? methods' do
          expect { U3dCore::Globals.method(:XXXX?) }.to raise_error(NameError)
        end

        it 'doesn\'t respond to the property' do
          expect { U3dCore::Globals.method(:XXXX) }.to raise_error(NameError)
        end
      end
    end
  end
end
