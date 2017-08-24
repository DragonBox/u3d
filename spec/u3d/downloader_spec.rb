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
require 'u3d/unity_version_definition'

describe U3d do
  describe U3d::Downloader do
    describe '#download_modules' do
      it 'raises an error when specifying a definition with unknown operating system' do
        definition = U3d::UnityVersionDefinition.new('1.2.3f4', :fakeos, nil)
        expect { U3d::Downloader.download_modules(definition, packages: []) }.to raise_error ArgumentError, /[oO]perating system.*/
      end

      context 'when downloading for Linux' do
        before(:each) do
          allow(U3d::INIparser).to receive(:load_ini) { {} }
          @definition = U3d::UnityVersionDefinition.new('1.2.3f4', :linux, nil)
        end

        it 'initializes the Validator and Downloader' do
          expect(U3d::LinuxValidator).to receive(:new)
          expect(U3d::Downloader::LinuxDownloader).to receive(:new)

          U3d::Downloader.download_modules(@definition, packages: [])
        end

        it 'does nothing when no packages are specified' do
          expect(U3dCore::CommandExecutor).to_not receive(:execute)
          expect(U3d::Downloader).to_not receive(:get_package)

          U3d::Downloader.download_modules(@definition, packages: [])
        end

        it 'downloads each specified package' do
          allow(U3dCore::CommandExecutor).to receive(:execute) {}
          expect(U3d::Downloader).to receive(:get_package).with(anything, anything, 'packageA', @definition, anything) {}

          U3d::Downloader.download_modules(@definition, packages: ['packageA'])
        end

        it 'makes sure that downloaded packages are executable' do
          allow(U3d::Downloader).to receive(:get_package).with(anything, anything, 'packageA', @definition, anything).and_wrap_original do |m, *args|
            args[4] << ['packageA', 'filepath', {}]
          end
          expect(U3dCore::CommandExecutor).to receive(:execute).with(command: 'chmod a+x filepath') {}

          U3d::Downloader.download_modules(@definition, packages: ['packageA'])
        end
      end

      context 'when downloading for Mac' do
        before(:each) do
          allow(U3d::INIparser).to receive(:load_ini) { {} }
          @definition = U3d::UnityVersionDefinition.new('1.2.3f4', :mac, nil)
        end

        it 'initializes the Validator and Downloader' do
          expect(U3d::MacValidator).to receive(:new)
          expect(U3d::Downloader::MacDownloader).to receive(:new)

          U3d::Downloader.download_modules(@definition, packages: [])
        end

        it 'does nothing when no packages are specified' do
          expect(U3d::Downloader).to_not receive(:get_package)

          U3d::Downloader.download_modules(@definition, packages: [])
        end

        it 'downloads each specified package' do
          expect(U3d::Downloader).to receive(:get_package).with(anything, anything, 'packageA', @definition, anything) {}

          U3d::Downloader.download_modules(@definition, packages: ['packageA'])
        end
      end

      context 'when downloading for Windows' do
        before(:each) do
          allow(U3d::INIparser).to receive(:load_ini) { {} }
          @definition = U3d::UnityVersionDefinition.new('1.2.3f4', :win, nil)
        end

        it 'initializes the Validator and Downloader' do
          expect(U3d::WindowsValidator).to receive(:new)
          expect(U3d::Downloader::WindowsDownloader).to receive(:new)

          U3d::Downloader.download_modules(@definition, packages: [])
        end

        it 'does nothing when no packages are specified' do
          expect(U3d::Downloader).to_not receive(:get_package)

          U3d::Downloader.download_modules(@definition, packages: [])
        end

        it 'downloads each specified package' do
          expect(U3d::Downloader).to receive(:get_package).with(anything, anything, 'packageA', @definition, anything) {}

          U3d::Downloader.download_modules(@definition, packages: ['packageA'])
        end
      end
    end

    describe U3d::Downloader::LinuxDownloader do
      before(:all) do
        @downloader = U3d::Downloader::LinuxDownloader.new
      end

      describe '.destination_for' do
        it 'returns the correct destination the Unity installer' do
          expect(U3d::Utils).to receive(:ensure_dir) {}
          allow(U3d::INIparser).to receive(:load_ini) { { 'Unity' => { 'url' => 'http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f4+20160628.sh' } } }

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :linux, nil)

          expect(
            @downloader.destination_for(
              'Unity',
              definition
            )
          ).to eql File.join("#{ENV['HOME']}", 'Downloads', 'Unity_Packages', '1.2.3f4', 'unity-editor-installer-1.2.3f4+20160628.sh')
        end
      end

      describe '.url_for' do
        it 'returns the correct url for the Unity installer' do
          allow(U3d::INIparser).to receive(:load_ini) { { 'Unity' => { 'url' => 'http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f4+20160628.sh' } } }

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :linux, { '1.2.3f4' => 'http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f4+20160628.sh' })
          expect(
            @downloader.url_for(
              'Unity',
              definition
            )
          ).to eql 'http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f4+20160628.sh'
        end
      end
    end

    describe U3d::Downloader::MacDownloader do
      before(:all) do
        @downloader = U3d::Downloader::MacDownloader.new
      end


      describe '.destination_for' do
        it 'returns the correct destination the specified package' do
          expect(U3d::Utils).to receive(:ensure_dir) {}
          allow(U3d::INIparser).to receive(:load_ini) { { 'package' => { 'url' => 'MacEditorInstaller/Unity.pkg' } } }

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :mac, nil)

          expect(
            @downloader.destination_for(
              'package',
              definition
            )
          ).to eql File.join("#{ENV['HOME']}", 'Downloads', 'Unity_Packages', '1.2.3f4', 'Unity.pkg')
        end
      end

      describe '.url_for' do
        it 'returns the correct url for the specified package' do
          allow(U3d::INIparser).to receive(:load_ini) { { 'package' => { 'url' => 'MacEditorInstaller/Unity.pkg' } } }

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :mac, { '1.2.3f4' => 'http://download.unity3d.com/download_unity/d3101c3b8468/' })
          expect(
            @downloader.url_for(
              'package',
              definition
            )
          ).to eql 'http://download.unity3d.com/download_unity/d3101c3b8468/MacEditorInstaller/Unity.pkg'
        end
      end
    end

    describe U3d::Downloader::WindowsDownloader do
      before(:all) do
        @downloader = U3d::Downloader::WindowsDownloader.new
      end


      describe '.destination_for' do
        it 'returns the correct destination the specified package' do
          expect(U3d::Utils).to receive(:ensure_dir) {}
          allow(U3d::INIparser).to receive(:load_ini) { { 'package' => { 'url' => 'Windows64EditorInstaller/UnitySetup64.exe' } } }

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :win, nil)

          expect(
            @downloader.destination_for(
              'package',
              definition
            )
          ).to eql File.join("#{ENV['HOME']}", 'Downloads', 'Unity_Packages', '1.2.3f4', 'UnitySetup64.exe')
        end
      end

      describe '.url_for' do
        it 'returns the correct url for the specified package' do
          allow(U3d::INIparser).to receive(:load_ini) { { 'package' => { 'url' => 'Windows64EditorInstaller/UnitySetup64.exe' } } }

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :win, { '1.2.3f4' => 'http://download.unity3d.com/download_unity/d3101c3b8468/' })
          expect(
            @downloader.url_for(
              'package',
              definition
            )
          ).to eql 'http://download.unity3d.com/download_unity/d3101c3b8468/Windows64EditorInstaller/UnitySetup64.exe'
        end
      end
    end
  end
end
