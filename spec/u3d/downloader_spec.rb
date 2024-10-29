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
require 'u3d/unity_version_definition'
require 'support/setups'

describe U3d do
  describe U3d::Downloader do
    describe '#download_modules' do
      it 'raises an error when specifying a definition with unknown operating system' do
        mock_unity_modules
        definition = U3d::UnityVersionDefinition.new('1.2.3f4', :fakeos, nil)
        expect { U3d::Downloader.download_modules(definition, packages: []) }.to raise_error ArgumentError, /[oO]perating system.*/
      end

      context 'when downloading for Linux' do
        before(:each) do
          allow(U3d::UnityModule).to receive(:load_modules) { [] }
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
          allow(U3d::Downloader).to receive(:get_package).with(anything, anything, 'packageA', @definition, anything).and_wrap_original do |_m, *args|
            args[4] << ['packageA', 'filepath', {}]
          end

          U3d::Downloader.download_modules(@definition, packages: ['packageA'])
        end
      end

      context 'when downloading for Mac' do
        before(:each) do
          allow(U3d::UnityModule).to receive(:load_modules) { [] }
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
          allow(U3d::UnityModule).to receive(:load_modules) { [] }
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

    describe '#local_files' do
      it 'raises an error when specifying a definition with unknown operating system' do
        mock_unity_modules
        definition = U3d::UnityVersionDefinition.new('1.2.3f4', :fakeos, nil)
        expect { U3d::Downloader.local_files(definition, packages: []) }.to raise_error ArgumentError, /[oO]perating system.*/
      end

      context 'when downloading for Linux' do
        before(:each) do
          allow(U3d::UnityModule).to receive(:load_modules) { [] }
          @definition = U3d::UnityVersionDefinition.new('1.2.3f4', :linux, nil)
        end

        it 'initializes the Validator and Downloader' do
          expect(U3d::LinuxValidator).to receive(:new)
          expect(U3d::Downloader::LinuxDownloader).to receive(:new)

          U3d::Downloader.local_files(@definition, packages: [])
        end

        it 'does nothing when no packages are specified' do
          downloader = double('LinuxDownloader')
          allow(U3d::Downloader::LinuxDownloader).to receive(:new) { downloader }
          expect(downloader).to_not receive(:destination_for)

          U3d::Downloader.local_files(@definition, packages: [])
        end

        it 'makes sure all files are present for specified package' do
          downloader = double('LinuxDownloader')
          allow(U3d::Downloader::LinuxDownloader).to receive(:new) { downloader }
          allow(downloader).to receive(:destination_for) { 'fileA' }

          # Return false to skip loop and increase test speed
          expect(File).to receive(:file?).with('fileA') { false }

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'logs an error if no file is found for a package' do
          downloader = double('LinuxDownloader')
          allow(U3d::Downloader::LinuxDownloader).to receive(:new) { downloader }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { false }

          expect(U3d::UI).to receive(:error)

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'makes sure all present files are valid for specified package' do
          downloader = double('LinuxDownloader')
          validator = double('LinuxValidator')
          allow(U3d::Downloader::LinuxDownloader).to receive(:new) { downloader }
          allow(U3d::LinuxValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }

          # Return false to skip loop and increase test speed
          expect(validator).to receive(:validate).with(anything, 'fileA', anything) { false }

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'logs a warning and skip the package if present file is not valid' do
          downloader = double('LinuxDownloader')
          validator = double('LinuxValidator')
          allow(U3d::Downloader::LinuxDownloader).to receive(:new) { downloader }
          allow(U3d::LinuxValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }
          allow(validator).to receive(:validate).with(anything, 'fileA', anything) { false }

          expect(U3d::UI).to receive(:important)
          expect(U3d::Downloader.local_files(@definition, packages: ['packageA'])).to be_empty
        end

        it 'returns a correct value when file presents for specified packages are valid' do
          @definition.ini = { 'packageA' => { 'test' => true } }
          package_definition = double(U3d::UnityModule, id: 'packagea')
          @definition.send(:packages=, [package_definition])
          downloader = double('LinuxDownloader')
          validator = double('LinuxValidator')
          allow(U3d::Downloader::LinuxDownloader).to receive(:new) { downloader }
          allow(U3d::LinuxValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }
          allow(validator).to receive(:validate).with(anything, 'fileA', anything) { true }

          expect(U3d::Downloader.local_files(@definition, packages: ['packageA'])).to eql [['packageA', 'fileA', package_definition]]
        end
      end

      context 'when downloading for Mac' do
        before(:each) do
          allow(U3d::UnityModule).to receive(:load_modules) { [] }
          @definition = U3d::UnityVersionDefinition.new('1.2.3f4', :mac, nil)
        end

        it 'initializes the Validator and Downloader' do
          expect(U3d::MacValidator).to receive(:new)
          expect(U3d::Downloader::MacDownloader).to receive(:new)

          U3d::Downloader.local_files(@definition, packages: [])
        end

        it 'does nothing when no packages are specified' do
          downloader = double('MacDownloader')
          allow(U3d::Downloader::MacDownloader).to receive(:new) { downloader }
          expect(downloader).to_not receive(:destination_for)

          U3d::Downloader.local_files(@definition, packages: [])
        end

        it 'makes sure all files are present for specified package' do
          downloader = double('MacDownloader')
          allow(U3d::Downloader::MacDownloader).to receive(:new) { downloader }
          allow(downloader).to receive(:destination_for) { 'fileA' }

          # Return false to skip loop and increase test speed
          expect(File).to receive(:file?).with('fileA') { false }

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'logs an error if no file is found for a package' do
          downloader = double('MacDownloader')
          allow(U3d::Downloader::MacDownloader).to receive(:new) { downloader }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { false }

          expect(U3d::UI).to receive(:error)

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'makes sure all present files are valid for specified package' do
          downloader = double('MacDownloader')
          validator = double('MacValidator')
          allow(U3d::Downloader::MacDownloader).to receive(:new) { downloader }
          allow(U3d::MacValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }

          # Return false to skip loop and increase test speed
          expect(validator).to receive(:validate).with(anything, 'fileA', anything) { false }

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'logs a warning and skip the package if present file is not valid' do
          downloader = double('MacDownloader')
          validator = double('MacValidator')
          allow(U3d::Downloader::MacDownloader).to receive(:new) { downloader }
          allow(U3d::MacValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }
          allow(validator).to receive(:validate).with(anything, 'fileA', anything) { false }

          expect(U3d::UI).to receive(:important)
          expect(U3d::Downloader.local_files(@definition, packages: ['packageA'])).to be_empty
        end

        it 'returns a correct value when file presents for specified packages are valid' do
          package_definition = double(U3d::UnityModule, id: 'packagea')
          @definition.send(:packages=, [package_definition])
          downloader = double('MacDownloader')
          validator = double('MacValidator')
          allow(U3d::Downloader::MacDownloader).to receive(:new) { downloader }
          allow(U3d::MacValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }
          allow(validator).to receive(:validate).with(anything, 'fileA', anything) { true }

          expect(U3d::Downloader.local_files(@definition, packages: ['packageA'])).to eql [['packageA', 'fileA', package_definition]]
        end
      end

      context 'when downloading for Windows' do
        before(:each) do
          allow(U3d::UnityModule).to receive(:load_modules) { [] }
          @definition = U3d::UnityVersionDefinition.new('1.2.3f4', :win, nil)
        end

        it 'initializes the Validator and Downloader' do
          expect(U3d::WindowsValidator).to receive(:new)
          expect(U3d::Downloader::WindowsDownloader).to receive(:new)

          U3d::Downloader.local_files(@definition, packages: [])
        end

        it 'does nothing when no packages are specified' do
          downloader = double('WindowsDownloader')
          allow(U3d::Downloader::WindowsDownloader).to receive(:new) { downloader }
          expect(downloader).to_not receive(:destination_for)

          U3d::Downloader.local_files(@definition, packages: [])
        end

        it 'makes sure all files are present for specified package' do
          downloader = double('WindowsDownloader')
          allow(U3d::Downloader::WindowsDownloader).to receive(:new) { downloader }
          allow(downloader).to receive(:destination_for) { 'fileA' }

          # Return false to skip loop and increase test speed
          expect(File).to receive(:file?).with('fileA') { false }

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'logs an error if no file is found for a package' do
          downloader = double('WindowsDownloader')
          allow(U3d::Downloader::WindowsDownloader).to receive(:new) { downloader }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { false }

          expect(U3d::UI).to receive(:error)

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'makes sure all present files are valid for specified package' do
          downloader = double('WindowsDownloader')
          validator = double('WindowsValidator')
          allow(U3d::Downloader::WindowsDownloader).to receive(:new) { downloader }
          allow(U3d::WindowsValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }

          # Return false to skip loop and increase test speed
          expect(validator).to receive(:validate).with(anything, 'fileA', anything) { false }

          U3d::Downloader.local_files(@definition, packages: ['packageA'])
        end

        it 'logs a warning and skip the package if present file is not valid' do
          downloader = double('WindowsDownloader')
          validator = double('WindowsValidator')
          allow(U3d::Downloader::WindowsDownloader).to receive(:new) { downloader }
          allow(U3d::WindowsValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }
          allow(validator).to receive(:validate).with(anything, 'fileA', anything) { false }

          expect(U3d::UI).to receive(:important)
          expect(U3d::Downloader.local_files(@definition, packages: ['packageA'])).to be_empty
        end

        it 'returns a correct value when file presents for specified packages are valid' do
          package_definition = double(U3d::UnityModule, id: 'packagea')
          @definition.send(:packages=, [package_definition])
          downloader = double('WindowsDownloader')
          validator = double('WindowsValidator')
          allow(U3d::Downloader::WindowsDownloader).to receive(:new) { downloader }
          allow(U3d::WindowsValidator).to receive(:new) { validator }
          allow(downloader).to receive(:destination_for) { 'fileA' }
          allow(File).to receive(:file?).with('fileA') { true }
          allow(validator).to receive(:validate).with(anything, 'fileA', anything) { true }

          expect(U3d::Downloader.local_files(@definition, packages: ['packageA'])).to eql [['packageA', 'fileA', package_definition]]
        end
      end
    end

    describe U3d::Downloader::LinuxDownloader do
      before(:all) do
        @downloader = U3d::Downloader::LinuxDownloader.new
        @url = 'http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f4+20160628.sh'
      end

      describe '.destination_for' do
        it 'returns the correct default destination for the Unity installer' do
          with_env_values('U3D_DOWNLOAD_PATH' => nil) do
            expect(U3d::Utils).to receive(:final_url).with(@url).and_return(@url)
            expect(U3d::Utils).to receive(:ensure_dir) {}
            mock_unity_modules(module_params: [{ id: 'unity', url: @url }])

            definition = U3d::UnityVersionDefinition.new('1.2.3f4', :linux, nil)

            expect(
              @downloader.destination_for(
                'unity',
                definition
              )
            ).to eql File.expand_path(File.join(Dir.home, 'Downloads', 'Unity_Packages', '1.2.3f4', 'unity-editor-installer-1.2.3f4+20160628.sh'))
          end
        end

        it 'returns the custom destination for the Unity installer when the environment variable is specified' do
          with_env_values('U3D_DOWNLOAD_PATH' => '/foo') do
            expect(U3d::Utils).to receive(:final_url).with(@url).and_return(@url)
            expect(U3d::Utils).to receive(:ensure_dir) {}
            mock_unity_modules(module_params: [{ id: 'unity', url: @url }])

            definition = U3d::UnityVersionDefinition.new('1.2.3f4', :linux, nil)

            expect(
              @downloader.destination_for(
                'unity',
                definition
              )
            ).to eql File.join(File.expand_path('/foo'), '1.2.3f4', 'unity-editor-installer-1.2.3f4+20160628.sh')
          end
        end
      end

      describe '.url_for' do
        it 'returns the correct url for the Unity installer' do
          expect(U3d::Utils).to receive(:final_url).with(@url).and_return(@url)
          mock_unity_modules(module_params: [{ id: 'unity', url: @url }])

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :linux, { '1.2.3f4' => @url })
          expect(
            @downloader.url_for(
              'unity',
              definition
            )
          ).to eql @url
        end
      end
    end

    describe U3d::Downloader::MacDownloader do
      before(:all) do
        @downloader = U3d::Downloader::MacDownloader.new

        @url = 'http://download.unity3d.com/download_unity/d3101c3b8468/'
        @path = 'MacEditorInstaller/Unity.pkg'
        @final_url = "#{@url}#{@path}"
      end

      describe '.destination_for' do
        it 'returns the correct default destination for the specified package' do
          with_env_values('U3D_DOWNLOAD_PATH' => nil) do
            expect(U3d::Utils).to receive(:ensure_dir) {}
            mock_unity_modules(module_params: [{ id: 'package', url: @path }])

            definition = U3d::UnityVersionDefinition.new('1.2.3f4', :mac, { '1.2.3f4' => @url })

            expect(
              @downloader.destination_for(
                'package',
                definition
              )
            ).to eql File.expand_path(File.join(Dir.home, 'Downloads', 'Unity_Packages', '1.2.3f4', 'Unity.pkg'))
          end
        end

        it 'returns the custom destination for the specified package when the environment variable is specified' do
          with_env_values('U3D_DOWNLOAD_PATH' => '/foo') do
            expect(U3d::Utils).to receive(:ensure_dir) {}
            mock_unity_modules(module_params: [{ id: 'package', url: @path }])

            definition = U3d::UnityVersionDefinition.new('1.2.3f4', :mac, { '1.2.3f4' => @url })

            expect(
              @downloader.destination_for(
                'package',
                definition
              )
            ).to eql File.join(File.expand_path('/foo'), '1.2.3f4', 'Unity.pkg')
          end
        end
      end

      describe '.url_for' do
        it 'returns the correct url for the specified package' do
          mock_unity_modules(module_params: [{ id: 'package', url: @path }])

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :mac, { '1.2.3f4' => @url })
          expect(
            @downloader.url_for(
              'package',
              definition
            )
          ).to eql @final_url
        end
      end
    end

    describe U3d::Downloader::WindowsDownloader do
      before(:all) do
        @downloader = U3d::Downloader::WindowsDownloader.new
        @url = 'http://download.unity3d.com/download_unity/d3101c3b8468/'
        @path = 'Windows64EditorInstaller/UnitySetup64.exe'
        @final_url = "#{@url}#{@path}"
      end

      describe '.destination_for' do
        it 'returns the correct default destination the specified package' do
          with_env_values('U3D_DOWNLOAD_PATH' => nil) do
            expect(U3d::Utils).to receive(:ensure_dir) {}
            mock_unity_modules(module_params: [{ id: 'package', url: @path }])

            definition = U3d::UnityVersionDefinition.new('1.2.3f4', :win, { '1.2.3f4' => @url })

            expect(
              @downloader.destination_for(
                'package',
                definition
              )
            ).to eql File.expand_path(File.join(Dir.home, 'Downloads', 'Unity_Packages', '1.2.3f4', 'UnitySetup64.exe'))
          end
        end

        it 'returns the custom destination for the specified package when the environment variable is specified' do
          with_env_values('U3D_DOWNLOAD_PATH' => '/foo') do
            expect(U3d::Utils).to receive(:ensure_dir) {}
            mock_unity_modules(module_params: [{ id: 'package', url: @path }])

            definition = U3d::UnityVersionDefinition.new('1.2.3f4', :win, { '1.2.3f4' => @url })

            expect(
              @downloader.destination_for(
                'package',
                definition
              )
            ).to eql File.join(File.expand_path('/foo'), '1.2.3f4', 'UnitySetup64.exe')
          end
        end
      end

      describe '.url_for' do
        it 'returns the correct url for the specified package' do
          mock_unity_modules(module_params: [{ id: 'package', url: @path }])

          definition = U3d::UnityVersionDefinition.new('1.2.3f4', :win, { '1.2.3f4' => @url })
          expect(
            @downloader.url_for(
              'package',
              definition
            )
          ).to eql @final_url
        end
      end
    end
  end
end
