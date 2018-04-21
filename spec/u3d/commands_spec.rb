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

require 'u3d/commands'
require 'support/installations'
require 'support/setups'

describe U3d do
  describe U3d::Commands do
    # ---
    # LIST_INSTALLED
    # ---
    describe "#list_installed" do
      it 'logs a message when no version is installed' do
        installer = double_installer
        expect(installer).to receive(:sanitize_installs)
        expect(installer).to receive(:installed_sorted_by_versions) { [] }

        expect(U3d::UI).to receive(:important).with(/[nN]o.*install/) {}

        U3d::Commands.list_installed
      end

      context 'when one or more version are installed' do
        it 'logs installed version when there is only one' do
          sorted_installed = [fake_installation('1.2.3f4')]
          installer = double_installer
          expect(installer).to receive(:sanitize_installs)
          expect(installer).to receive(:installed_sorted_by_versions) { sorted_installed }

          expect(U3d::UI).to receive(:message).with(/1.2.3f4.*foo/)

          expect(U3d::Commands.list_installed).to eq sorted_installed
        end

        it 'logs installed packages as well when --packages option is specified' do
          sorted_installed = [fake_installation('1.2.3f4', packages: %w[packageA packageB])]
          installer = double_installer
          expect(installer).to receive(:sanitize_installs)
          expect(installer).to receive(:installed_sorted_by_versions) { sorted_installed }

          expect(U3d::UI).to receive(:message).with(/1.2.3f4.*foo/)
          expect(U3d::UI).to receive(:message).with(/Packages/)
          expect(U3d::UI).to receive(:message).with(/packageA/)
          expect(U3d::UI).to receive(:message).with(/packageB/)

          U3d::Commands.list_installed(options: { packages: true })
        end

        it 'logs sorted versions when several are installed' do
          i1 = fake_installation('1.2.3f6')
          i2 = fake_installation('1.2.3b2')
          i3 = fake_installation('1.2.3f4')

          sorted_installed = [i2, i3, i1]
          installer = double_installer
          expect(installer).to receive(:sanitize_installs)
          expect(installer).to receive(:installed_sorted_by_versions) { sorted_installed }

          expect(U3d::UI).to receive(:message).with(/1.2.3b2.*foo/).ordered
          expect(U3d::UI).to receive(:message).with(/1.2.3f4.*foo/).ordered
          expect(U3d::UI).to receive(:message).with(/1.2.3f6.*foo/).ordered

          expect(U3d::Commands.list_installed).to eq sorted_installed
        end
      end
      # when we support a specific version number (e.g. to list the packages of that version)
      #   request a non existing version number -> fail
      #   request an existing version number -> only that version
      #   TODO: Implement me
      xcontext 'when specifying a version number' do
        xit 'raises an error when version does not exist' do
        end

        xit 'displays only specified version if correct' do
        end
      end
    end

    # ---
    # LIST_AVAILABLE
    # ---
    describe "#list_available" do
      context 'common' do
        it 'raises an error when specifying an invalid operating system' do
          expect { U3d::Commands.list_available(options: { operating_system: 'NotAnOs' }) }.to raise_error StandardError
        end

        it 'forces the cache to refresh with option --force' do
          on_fake_os

          expect(U3d::Cache).to receive(:new).with(
            force_os: :fakeos,
            offline: false,
            force_refresh: true,
            central_cache: true
          ) { { 'fakeos' => { 'versions' => {} } } }

          U3d::Commands.list_available(options: { force: true })
        end

        #   request a non existing version number -> fail
        #   QUESTION: Raises an error instead of logging?
        it 'logs an error when specifying a non existing version' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

          expect(U3d::UI).to receive(:error)

          U3d::Commands.list_available(options: { unity_version: 'not.a.version' })
        end

        it 'only logs specified version using fully described version' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

          expect(U3d::UI).to receive(:message).with(/.*1.2.3f4.*fakeurl.*/)

          U3d::Commands.list_available(options: { unity_version: '1.2.3f4' })
        end

        it 'only logs specified version found using partial version' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl', '1.3.3f4' => 'fakeurl' } })

          expect(U3d::UI).to receive(:message).with(/.*1.2.3f4.*fakeurl.*/)

          U3d::Commands.list_available(options: { unity_version: '1.2' })
        end

        it 'only logs specified version found using regular expression' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl', '1.3.3f4' => 'fakeurl' } })

          expect(U3d::UI).to receive(:message).with(/.*1.2.3f4.*fakeurl.*/)

          U3d::Commands.list_available(options: { unity_version: '1\.2\..+' })
        end

        context 'when parsing user OS input' do
          it 'uses correct input' do
            fakeos = double('os')
            fakeos_sym = double('os_sym')
            oses = double('oses')
            allow(fakeos).to receive(:to_sym) { fakeos_sym }
            allow(U3d::Helper).to receive(:operating_systems) { oses }
            expect(oses).to receive(:include?).with(fakeos_sym) { true }
            allow(fakeos_sym).to receive(:id2name) { 'fakeos' }

            expect(U3d::Cache).to receive(:new).with(force_os: fakeos_sym, offline: false, force_refresh: false, central_cache: true) { { 'fakeos' => { 'versions' => {} } } }

            U3d::Commands.list_available(options: { operating_system: fakeos, force: false })
          end

          it 'raises an error with invalid input' do
            fakeos = double('os')
            fakeos_sym = double('os_sym')
            oses = double('oses')
            allow(fakeos).to receive(:to_sym) { fakeos_sym }
            allow(U3d::Helper).to receive(:operating_systems) { oses }
            expect(oses).to receive(:include?).with(fakeos_sym) { false }
            allow(oses).to receive(:join) { '' }

            expect { U3d::Commands.list_available(options: { operating_system: fakeos }) }.to raise_error StandardError
          end

          it 'assumes the OS if nothing specified' do
            expect(U3d::Helper).to receive(:operating_system) { :fakeos }
            expect(U3d::Cache).to receive(:new).with(force_os: :fakeos, offline: false, force_refresh: false, central_cache: true) { { 'fakeos' => { 'versions' => {} } } }

            U3d::Commands.list_available(options: { force: false })
          end
        end
      end

      context 'when listing cached versions' do
        it 'lists versions in proper order' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => {
                            '1.2.3f4' => 'fakeurl',
                            '1.2.3f6' => 'fakeurl',
                            '1.2.3b2' => 'fakeurl',
                            '0.0.0f4' => 'fakeurl'
                          } })

          expect(U3d::UI).to receive(:message).with(/.*0.0.0f4.*fakeurl.*/).ordered
          expect(U3d::UI).to receive(:message).with(/.*1.2.3b2.*fakeurl.*/).ordered
          expect(U3d::UI).to receive(:message).with(/.*1.2.3f4.*fakeurl.*/).ordered
          expect(U3d::UI).to receive(:message).with(/.*1.2.3f6.*fakeurl.*/).ordered

          U3d::Commands.list_available(options: { force: false })
        end

        it 'filters versions based on specified correct release type' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => {
                            '1.2.3f4' => 'fakeurl',
                            '1.2.3f6' => 'fakeurl',
                            '1.2.3b2' => 'fakeurl',
                            '0.0.0f4' => 'fakeurl'
                          } })

          expect(U3d::UI).to receive(:message).with(/.*0.0.0f4.*fakeurl.*/)
          expect(U3d::UI).to_not receive(:message).with(/.*1.2.3b2.*fakeurl.*/)
          expect(U3d::UI).to receive(:message).with(/.*1.2.3f4.*fakeurl.*/)
          expect(U3d::UI).to receive(:message).with(/.*1.2.3f6.*fakeurl.*/)

          U3d::Commands.list_available(options: { force: false, release_level: 'stable' })
        end

        it 'displays packages when --packages options is specified' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

          expect(U3d::INIparser).to receive(:load_ini).with(
            '1.2.3f4',
            { '1.2.3f4' => 'fakeurl' },
            os: :fakeos
          ) { { 'packageA' => '', 'packageB' => '' } }

          expect(U3d::UI).to receive(:message).with(/.*1.2.3f4.*fakeurl.*/)
          expect(U3d::UI).to receive(:message).with(/Packages/)
          expect(U3d::UI).to receive(:message).with(/packageA/)
          expect(U3d::UI).to receive(:message).with(/packageB/)

          U3d::Commands.list_available(options: { force: false, packages: true })
        end
      end

      #   make sure this works properly on Linux support with our fake INI file
      #   NOTE: Should be tested in INIparser
    end

    # ---
    # INSTALL ONLY
    # ---
    describe "#install" do
      context 'common download' do
        xit "raises an error if both download and install are disabled" do
        end
        #   no version specified -> look for version in current project folder if any
        context 'when no version is specified' do
          it 'fetches the version of the project in the current folder' do
            in_a_project(version: '1.2.3f4')
            are_installed([])
            on_fake_os
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            definition = expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: ['Unity'])

            expect(U3d::Downloader).to receive(:fetch_modules).with(
              definition,
              packages: ["Unity"],
              download: true
            ) { [] }
            U3d::Commands.install(
              args: [],
              options: {
                install: false,
                download: true,
                packages: ['Unity']
              }
            )
          end

          it 'raises an error if not in a project folder' do
            not_in_a_project

            expect do
              U3d::Commands.install(
                args: [],
                options: {
                  install: false,
                  download: true,
                  packages: ['Unity']
                }
              )
            end.to raise_error U3dCore::Interface::UIError
          end
        end

        #   request an aliased version -> resolve alias
        it 'resolves alias when passed as a version' do
          on_fake_os
          are_installed([])
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
          definition = expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: ['Unity'])

          expect(U3d::Downloader).to receive(:fetch_modules).with(
            definition,
            packages: ["Unity"],
            download: true
          )
          U3d::Commands.install(
            args: ['latest'],
            options: {
              install: false,
              download: true,
              packages: ['Unity']
            }
          )
        end

        #   request a non existing version number -> fail
        #   QUESTION: Raises an error instead of logging?
        it 'logs an error when specifying a non existing version' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

          expect(U3dCore::UI).to receive(:error) {}

          U3d::Commands.install(
            args: ['not.a.version'],
            options: {
              install: false,
              download: true,
              packages: ['Unity']
            }
          )
        end
        #   support downloading the not current platform -> not yet supported
        #   TODO: Implement me
        xit 'downloads versions for other os when option --operating_system is specified' do
        end
        #   support installing multiple versions at once -> not yet supported
        #   TODO: Implement me
        xit 'downloads several versions at once when specified' do
        end
      end

      context 'platforms without modules' do
        #   install a non discovered version -> installed
        it 'installs Unity when version is not yet present' do
          on_linux
          are_installed([])
          with_fake_cache('linux' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
          expect_privileges_check
          expected_definition('1.2.3f4', :linux, 'fakeurl', packages: %w[Unity])

          files = double('files')
          expect(U3d::Downloader).to receive(:download_modules) { files }

          expect(U3d::Installer).to receive(:install_modules).with(
            files,
            '1.2.3f4',
            installation_path: 'foo'
          ) {}

          U3d::Commands.install(
            args: ['1.2.3f4'],
            options: {
              install: true,
              download: true,
              installation_path: 'foo'
            }
          )
        end

        #   reinstall a discovered version -> skipped, no credentials asked
        it 'does not ask for credentials and does nothing when version is already present' do
          on_linux
          with_fake_cache('linux' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
          are_installed([fake_linux('1.2.3f4')])
          expect_no_privileges_check
          expect_no_download
          expect_no_install

          U3d::Commands.install(
            args: ['1.2.3f4'],
            options: {
              install: true,
              download: true
            }
          )
        end

        #   force reinstall a discovered version -> installed (not yet implemented)
        #   TODO: Implement me
        xit 'forces reinstallation of Unity with option --force' do
        end
      end

      context 'platforms with modules' do
        context 'when Unity version is not yet installed' do
          it 'logs an error when Unity is not specified in the packages' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_no_privileges_check
            expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: %w[packageA packageB])

            expect(U3dCore::UI).to receive(:error) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: true,
                packages: %w[packageA packageB]
              }
            )
          end

          it 'installs specified packages and Unity when specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: %w[Unity packageA packageB])

            files = double('files')
            expect(U3d::Downloader).to receive(:download_modules).with(
              definition,
              packages: %w[Unity packageA packageB]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: true,
                packages: %w[Unity packageA packageB],
                installation_path: 'foo'
              }
            )
          end

          it 'installs just Unity when no packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: %w[Unity])

            files = double('files')
            expect(U3d::Downloader).to receive(:download_modules).with(
              definition,
              packages: ['Unity']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: true,
                installation_path: 'foo'
              }
            )
          end

          it 'installs all available packages when --all option is used' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: %w[Unity WebGL Android])

            files = double('files')
            expect(U3d::Downloader).to receive(:download_modules).with(
              definition,
              packages: %w[Unity WebGL Android]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: true,
                all: true,
                installation_path: 'foo'
              }
            )
          end
        end

        context 'when Unity version is already installed' do
          #   add an existing editor or module to a discovered install -> skipped, no credentials asked
          it 'does not ask for credentials and does nothing when no packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            are_installed([fake_installation('1.2.3f4', packages: %w[packageA packageB])])
            expect_no_privileges_check
            expect_no_download
            expect_no_install

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: true,
                installation_path: 'foo'
              }
            )
          end

          it 'installs only uninstalled packages when packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            are_installed([fake_installation('1.2.3f4', packages: %w[packageA])])
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: %w[packageA packageB])

            files = double("files")
            expect(U3d::Downloader).to receive(:download_modules).with(
              definition,
              packages: ['packageB']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: true,
                installation_path: 'foo',
                packages: %w[packageA packageB]
              }
            )
          end

          #   force reinstall the editor + modules -> installed all (not yet implemented)
          #   TODO: Implement me
          xit 'forces complete reinstallation of specified packages with option --force' do
          end
        end
      end
    end

    # ---
    # DOWNLOAD ONLY
    # ---
    describe "#install" do
      context 'common install' do
        #   no version specified -> look for version in current project folder if any
        context 'when no version is specified' do
          it 'fetches the version of the project in the current folder' do
            in_a_project(version: '1.2.3f4')
            on_fake_os
            are_installed([])
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            definition = expected_definition('1.2.3f4', :fakeos, nil, packages: %w[Unity])

            expect_privileges_check
            expect(U3d::Downloader).to receive(:fetch_modules).with(
              definition,
              packages: ["Unity"],
              download: false
            ) { [] }

            U3d::Commands.install(
              args: [],
              options: {
                install: true,
                download: false,
                packages: ['Unity']
              }
            )
          end

          it 'raises an error if not in a project folder' do
            not_in_a_project

            expect do
              U3d::Commands.install(
                args: [],
                options: {
                  install: true,
                  download: false,
                  packages: ['Unity']
                }
              )
            end.to raise_error U3dCore::Interface::UIError
          end
        end

        #   request a non existing version number -> do nothing
        it 'does not log an error when specifying a non existing version' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

          expect(U3dCore::UI).to receive(:error).with(/No version 'not.a.version'/)

          U3d::Commands.install(
            args: ['not.a.version'],
            options: {
              install: true,
              download: false,
              packages: ['Unity']
            }
          )
        end

        #   support installing multiple versions at once -> not yet supported
        #   TODO: Implement me
      end

      describe 'platforms without modules' do
        #   install a non discovered version -> installed
        it 'installs Unity when version is not yet present' do
          on_linux
          are_installed([])
          with_fake_cache('linux' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
          expect_privileges_check
          expected_definition('1.2.3f4', :linux, nil, packages: %w[Unity])

          files = double('files')
          expect(U3d::Downloader).to receive(:fetch_modules) { files }

          expect(U3d::Installer).to receive(:install_modules).with(
            files,
            '1.2.3f4',
            installation_path: 'foo'
          ) {}

          U3d::Commands.install(
            args: ['1.2.3f4'],
            options: {
              install: true,
              download: false,
              installation_path: 'foo'
            }
          )
        end

        #   reinstall a discovered version -> skipped, no credentials asked
        it 'does not ask for credentials and does nothing when version is already present' do
          on_linux
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
          are_installed([fake_linux('1.2.3f4')])
          expect_no_privileges_check
          expect_no_install

          U3d::Commands.install(
            args: ['1.2.3f4'],
            options: {
              install: true,
              download: false
            }
          )
        end

        #   force reinstall a discovered version -> installed (not yet implemented)
        #   TODO: Implement me
        xit 'forces reinstallation of Unity with option --force' do
        end
      end

      context 'platforms with modules' do
        context 'when Unity version is not yet installed' do
          it 'logs an error when Unity is not specified in the packages' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_no_privileges_check
            expected_definition('1.2.3f4', :fakeos, nil, packages: %w[packageA packageB])

            expect(U3dCore::UI).to receive(:error) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: false,
                packages: %w[packageA packageB]
              }
            )
          end

          it 'installs specified packages and Unity when specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, nil, packages: %w[Unity packageA packageB])

            files = double("files")
            expect(U3d::Downloader).to receive(:local_files).with(
              definition,
              packages: %w[Unity packageA packageB]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: false,
                packages: %w[Unity packageA packageB],
                installation_path: 'foo'
              }
            )
          end

          it 'installs just Unity when no packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, nil, packages: %w[Unity])

            files = double('files')
            expect(U3d::Downloader).to receive(:local_files).with(
              definition,
              packages: ['Unity']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: false,
                installation_path: 'foo'
              }
            )
          end

          it 'installs all available packages when --all option is used' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, 'fakeurl', packages: %w[Unity WebGL Android])

            files = double('files')
            expect(U3d::Downloader).to receive(:local_files).with(
              definition,
              packages: %w[Unity WebGL Android]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: false,
                all: true,
                installation_path: 'foo'
              }
            )
          end
        end

        context 'when Unity version is already installed' do
          #   add an existing editor or module to a discovered install -> skipped, no credentials asked
          it 'does not ask for credentials and does nothing when no packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            are_installed([fake_installation('1.2.3f4', packages: %w[packageA packageB])])
            expect_no_privileges_check
            expect_no_download
            expect_no_install

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: false,
                installation_path: 'foo'
              }
            )
          end

          it 'installs only uninstalled packages when packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            are_installed([fake_installation('1.2.3f4', packages: ['packageA'])])
            expect_privileges_check
            definition = expected_definition('1.2.3f4', :fakeos, nil, packages: %w[packageA packageB])

            files = double('files')
            expect(U3d::Downloader).to receive(:local_files).with(
              definition,
              packages: ['packageB']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.install(
              args: ['1.2.3f4'],
              options: {
                install: true,
                download: false,
                installation_path: 'foo',
                packages: %w[packageA packageB]
              }
            )
          end

          #   force reinstall the editor + modules -> installed all (not yet implemented)
          #   TODO: Implement me
          xit 'forces complete reinstallation of specified packages with option --force' do
          end
        end
      end
    end

    # ---
    # CREDENTIALS
    # ---
    describe "#credentials" do
      # invalid action name: fail
      # add
      #   add proper username/password -> added
      #   add invalid u/p -> not added
      # remove
      #   remove -> removed
      # check
      #   u/p doesn't exist -> display no credentials stored
      #   u valid as admin -> display valid
      #   u invalid as admin -> display invalid
      # return value
      #   commands should follow POSIX when they succeed to do what this want.
      #   proposed:
      #     add/remove should fail with 1 if operation fails to add or remove
      #     check: should fail with 1 if user not exist, 2 if invalid
    end

    # ---
    # PRETTIFY
    # ---
    describe "#prettify" do
      it 'raises an error if no file is specified' do
        expect { U3d::Commands.local_analyze(args: []) }.to raise_error ArgumentError
      end

      it 'raises an error if specified file does not exist' do
        allow(File).to receive(:exist?).with('foo') { false }
        expect { U3d::Commands.local_analyze(args: ['foo']) }.to raise_error ArgumentError
      end

      it 'prettifies the log if the specified file is correct' do
        allow(File).to receive(:exist?).with('foo') { true }
        analyzer = double('LogAnalyzer')
        file = double('file')
        lines = double('file.readlines')
        line = double('line')

        expect(U3d::LogAnalyzer).to receive(:new) { analyzer }
        expect(File).to receive(:open).with('foo', 'r').and_yield file
        expect(file).to receive(:readlines) { lines }
        expect(lines).to receive(:each).and_yield line
        expect(analyzer).to receive(:parse_line).with(line) {}

        U3d::Commands.local_analyze(args: ['foo'])
      end
      # fail if no file arg specified
      # fail if file arg not a file
      # FIXME: no way to specify a different log rule config right now
      # passes all lines through the log analyser with the configured (default) log rule
      #   QUESTION: EOL issue ? - what about logs from other platforms?
    end

    # ---
    # RUN
    # ---
    describe "#run" do
      let(:runner) do
        runner = double("Runner")
        allow(U3d::Runner).to receive(:new) { runner }
        runner
      end
      context 'inside a given unity project' do
        it "fails if it cannot find the project's unity version" do
          are_installed([])
          projectpath = 'fakepath'
          in_a_project(version: '1.2.3f4', path: projectpath)

          expect do
            U3d::Commands.run(
              options: {},
              run_args: []
            )
          end.to raise_error U3dCore::Interface::UIError, "Unity version '1.2.3f4' not found"
        end

        it "uses the project's unity version and path if there are no arguments" do
          unity = fake_installation('1.2.3f4')
          projectpath = 'fakepath'

          are_installed([unity])
          in_a_project(version: unity.version, path: projectpath)

          expect(runner).to receive(:run).with(unity, ['-projectpath', projectpath], raw_logs: nil)

          U3d::Commands.run(
            options: {},
            run_args: []
          )
        end

        it "uses the project's unity version and path if there are arguments" do
          unity = fake_installation('1.2.3f4')
          projectpath = 'fakepath'

          are_installed([unity])
          in_a_project(version: unity.version, path: projectpath)

          expect(runner).to receive(:run).with(unity, ['-projectpath', projectpath, "somearg"], raw_logs: nil)

          U3d::Commands.run(
            options: {},
            run_args: ["somearg"]
          )
        end

        it "prefers the user's unity version if passed as argument" do
          project_unity = fake_installation('1.2.3f4')
          other_unity = fake_installation('1.2.3p1')
          projectpath1 = 'fakepath'

          are_installed([project_unity, other_unity])
          in_a_project(version: project_unity.version, path: projectpath1)

          expect(runner).to receive(:run).with(other_unity, ['-projectpath', projectpath1, "somearg"], raw_logs: nil)

          U3d::Commands.run(
            options: { unity_version: other_unity.version },
            run_args: ["somearg"]
          )
        end

        it "prefers the user's unity project path if passed as argument" do
          project_unity = fake_installation('1.2.3f4')
          current_projectpath = 'fakepath'
          other_projectpath = 'fakepath2'

          are_installed([project_unity])
          in_a_project(version: project_unity.version, path: current_projectpath)

          expect(runner).to receive(:run).with(project_unity, ['-projectpath', other_projectpath, "somearg"], raw_logs: nil)

          U3d::Commands.run(
            options: {},
            run_args: ['-projectpath', other_projectpath, 'somearg']
          )
        end
      end
      context 'outside a unity project' do
        it 'fails if no unity version specified' do
          unity = fake_installation('1.2.3f4')
          are_installed([unity])

          runner = double("Runner")
          allow(U3d::Runner).to receive(:new) { runner }

          expect do
            U3d::Commands.run(
              options: {},
              run_args: []
            )
          end.to raise_error U3dCore::Interface::UIError, /Not sure which version of Unity to run/
        end
        it "fails if the specified version isn't installed" do
          nothing_installed

          expect do
            U3d::Commands.run(
              options: { unity_version: '1.2.3f4' },
              run_args: []
            )
          end.to raise_error U3dCore::Interface::UIError, /'1.2.3f4' not found/
        end
        it "runs with the specified unity, project version" do
          unity = fake_installation('1.2.3f4')
          projectpath = 'fakepath'

          are_installed([unity])

          expect(runner).to receive(:run).with(unity, ['-projectpath', projectpath], raw_logs: nil)

          U3d::Commands.run(
            options: { unity_version: unity.version },
            run_args: ["-projectpath", projectpath]
          )
        end
        it "runs with the specified unity, project version and raw_logs" do
          unity = fake_installation('1.2.3f4')
          projectpath = 'fakepath'

          are_installed([unity])

          expect(runner).to receive(:run).with(unity, ['-projectpath', projectpath], raw_logs: 'raaaww')

          U3d::Commands.run(
            options: { unity_version: unity.version, raw_logs: 'raaaww' },
            run_args: ["-projectpath", projectpath]
          )
        end
      end
    end
  end
end
