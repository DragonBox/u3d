require 'u3d/installer'
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
