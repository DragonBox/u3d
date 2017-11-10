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

require 'u3d/unity_project'
require 'u3d_core/helper'
require 'yaml'

describe U3d do
  describe U3d::UnityProject do
    describe '#editor_version' do
      before(:all) do
        @config = { 'm_EditorVersion' => 'test' }
        @project = U3d::UnityProject.new('foo')
      end

      before(:each) do
        allow(File).to receive(:exist?) { true }
        allow(File).to receive(:read) { 'bar' }
        allow(YAML).to receive(:safe_load) { @config }
      end

      describe 'when under Linux' do
        before(:each) do
          allow(U3d::Helper).to receive(:linux?) { true }
        end

        it 'leaves correct versions untouched' do
          @config = { 'm_EditorVersion' => '5.6.0f3' }
          expect(@project.editor_version).to eql('5.6.0f3')
        end

        it 'cleans versions that should be' do
          @config = { 'm_EditorVersion' => '2017.1.0xf3Linux' }
          expect(@project.editor_version).to eql('2017.1.0f3')
        end

        it 'does not change unrecognized versions' do
          @config = { 'm_EditorVersion' => 'very.special.version' }
          expect(@project.editor_version).to eql('very.special.version')
        end
      end

      describe 'when not under Linux' do
        before(:each) do
          allow(U3d::Helper).to receive(:linux?) { false }
        end

        it 'leaves correct versions untouched' do
          @config = { 'm_EditorVersion' => '5.6.0f3' }
          expect(@project.editor_version).to eql('5.6.0f3')
        end

        it 'does not act on Linux unclean versions' do
          @config = { 'm_EditorVersion' => '2017.1.0xf3Linux' }
          expect(@project.editor_version).to eql('2017.1.0xf3Linux')
        end

        it 'does not change unrecognized versions' do
          @config = { 'm_EditorVersion' => 'very.special.version' }
          expect(@project.editor_version).to eql('very.special.version')
        end
      end
    end
  end
end
