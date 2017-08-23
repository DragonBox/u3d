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
      # 0 version installed -> display message
      # 1 version, without option packages -> only version
      # multiple versions, with or without option packages, sorted
      # 1 version, with option packages -> also packages
      # when we support a specific version number (e.g. to list the packages of that version)
      #   request a non existing version number -> fail
      #   request an existing version number -> only that version
    end

    # ---
    # LIST_AVAILABLE
    # ---
    describe "#list_available" do
      describe 'common' do
        it 'raises an error when specifying an invalid operating system' do
          expect { U3d::Commands.list_available(options: { operating_system: 'NotAnOs' }) }.to raise_error StandardError
        end

        it 'forces the cache to refresh with option --force' do
          on_fake_os

          expect(U3d::Cache).to receive(:new).with(
            force_os: :fakeos,
            force_refresh: true
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

        it 'only logs specified version' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

          expect(U3d::UI).to receive(:message).with(/.*1.2.3f4.*fakeurl.*/)

          U3d::Commands.list_available(options: { unity_version: '1.2.3f4' })
        end

        describe 'when parsing user OS input' do
          it 'uses correct input' do
            fakeos = double('os')
            fakeos_sym = double('os_sym')
            oses = double('oses')
            allow(fakeos).to receive(:to_sym) { fakeos_sym }
            allow(U3d::Helper).to receive(:operating_systems) { oses }
            expect(oses).to receive(:include?).with(fakeos_sym) { true }
            allow(fakeos_sym).to receive(:id2name) { 'fakeos' }

            expect(U3d::Cache).to receive(:new).with(force_os: fakeos_sym, force_refresh: false) { { 'fakeos' => { 'versions' => {} } } }

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
            expect(U3d::Cache).to receive(:new).with(force_os: :fakeos, force_refresh: false) { { 'fakeos' => { 'versions' => {} } } }

            U3d::Commands.list_available(options: { force: false })
          end
        end
      end

      describe 'when listing cached versions' do
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
    # DOWNLOAD
    # ---
    describe "#download" do
      describe 'common' do
        #   no version specified -> look for version in current project folder if any
        describe 'when no version is specified' do
          it 'fetches the version of the project in the current folder' do
            in_a_project '1.2.3f4'
            on_fake_os
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              anything
            ) { [] }
            U3d::Commands.download(
              args: [],
              options: {
                no_install: true,
                packages: ['Unity']
              }
            )
          end

          it 'raises an error if not in a project folder' do
            not_in_a_project

            expect do
              U3d::Commands.download(
                args: [],
                options: {
                  no_install: true,
                  packages: ['Unity']
                }
              )
            end.to raise_error U3dCore::Interface::UIError
          end
        end

        #   request an aliased version -> resolve alias
        it 'resolves alias when passed as a version' do
          on_fake_os
          with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })

          expect(U3d::Downloader).to receive(:download_modules).with(
            '1.2.3f4',
            { '1.2.3f4' => 'fakeurl' },
            :fakeos,
            anything
          )
          U3d::Commands.download(
            args: ['latest'],
            options: {
              no_install: true,
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

          U3d::Commands.download(
            args: ['not.a.version'],
            options: {
              no_install: true,
              packages: ['Unity']
            }
          )
        end

        #   cache is outdated -> cache refreshed
        #   NOTE: This shoudln't be tested by Commands, but by Cache

        #   support downloading the not current platform -> not yet supported
        #   TODO: Implement me

        #   support installing multiple versions at once -> not yet supported
        #   TODO: Implement me
      end

      describe 'platforms without modules' do
        #   install a non discovered version -> installed
        it 'installs Unity when version is not yet present' do
          on_linux
          with_fake_cache('linux' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
          expect_privileges_check

          files = double('files')
          expect(U3d::Downloader).to receive(:download_modules) { files }

          expect(U3d::Installer).to receive(:install_modules).with(
            files,
            '1.2.3f4',
            installation_path: 'foo'
          ) {}

          U3d::Commands.download(
            args: ['1.2.3f4'],
            options: {
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

          U3d::Commands.download(
            args: ['1.2.3f4'],
            options: {}
          )
        end

        #   force reinstall a discovered version -> installed (not yet implemented)
        #   TODO: Implement me
        it 'forces reinstallation of Unity with option --force' do
          puts '      --- TODO ---'
        end
      end

      describe 'platforms with modules' do
        describe 'when Unity version is not yet installed' do
          it 'logs an error when Unity is not specified in the packages' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_no_privileges_check

            expect(U3dCore::UI).to receive(:error) {}

            U3d::Commands.download(
              args: ['1.2.3f4'],
              options: {
                packages: %w[packageA packageB]
              }
            )
          end

          it 'installs specified packages and Unity when specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            nothing_installed
            expect_privileges_check

            files = double('files')
            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              packages: %w[Unity packageA packageB]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.download(
              args: ['1.2.3f4'],
              options: {
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

            files = double('files')
            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              packages: ['Unity']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.download(
              args: ['1.2.3f4'],
              options: {
                installation_path: 'foo'
              }
            )
          end

          #   TODO: Reimplement --all option
          it 'installs all available packages when --all option is used' do
            puts '      --- TODO ---'
          end
        end

        describe 'when Unity version is already installed' do
          #   add an existing editor or module to a discovered install -> skipped, no credentials asked
          it 'does not ask for credentials and does nothing when no packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            are_installed([fake_installation('1.2.3f4', packages: %w[packageA packageB])])
            expect_no_privileges_check
            expect_no_download
            expect_no_install

            U3d::Commands.download(
              args: ['1.2.3f4'],
              options: {
                installation_path: 'foo'
              }
            )
          end

          it 'installs only uninstalled packages when packages are specified' do
            on_fake_os_not_linux
            with_fake_cache('fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } })
            are_installed([fake_installation('1.2.3f4', packages: ['packageA'])])
            expect_privileges_check

            files = double("files")
            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              packages: ['packageB']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.download(
              args: ['1.2.3f4'],
              options: {
                installation_path: 'foo',
                packages: %w[packageA packageB]
              }
            )
          end

          #   force reinstall the editor + modules -> installed all (not yet implemented)
          #   TODO: Implement me
          it 'forces complete reinstallation of specified packages with option --force' do
            puts '      --- TODO ---'
          end
        end
      end
    end

    # ---
    # LOCAL_INSTALL
    # ---
    describe "#local_install" do
      describe 'common' do
        #   no version specified -> look for version in current project folder if any
        describe 'when no version is specified' do
          it 'fetches the version of the project in the current folder' do
            in_a_project '1.2.3f4'
            on_fake_os
            expect_privileges_check

            expect(U3d::Downloader).to receive(:local_files).with(
              '1.2.3f4',
              :fakeos,
              anything
            ) { [] }
            U3d::Commands.local_install(
              args: [],
              options: {
                packages: ['Unity']
              }
            )
          end

          it 'raises an error if not in a project folder' do
            not_in_a_project

            expect do
              U3d::Commands.local_install(
                args: [],
                options: {
                  packages: ['Unity']
                }
              )
            end.to raise_error U3dCore::Interface::UIError
          end
        end

        #   request a non existing version number -> do nothing
        #   NOTE: This will be caught by Dowloader.local_file and error will be raised then
        #   QUESTION: Should we try to catch it sooner?
        it 'does not log an error when specifying a non existing version' do
          on_fake_os
          expect_privileges_check

          expect(U3d::Downloader).to receive(:local_files) {}

          # Allowed for testing purpose. It should not be reach in real case
          allow(U3d::Installer).to receive(:install_modules) {}

          U3d::Commands.local_install(
            args: ['not.a.version'],
            options: {
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
          expect_privileges_check

          files = double('files')
          expect(U3d::Downloader).to receive(:local_files) { files }

          expect(U3d::Installer).to receive(:install_modules).with(
            files,
            '1.2.3f4',
            installation_path: 'foo'
          ) {}

          U3d::Commands.local_install(
            args: ['1.2.3f4'],
            options: {
              installation_path: 'foo'
            }
          )
        end

        #   reinstall a discovered version -> skipped, no credentials asked
        it 'does not ask for credentials and does nothing when version is already present' do
          on_linux
          are_installed([fake_linux('1.2.3f4')])
          expect_no_privileges_check
          expect_no_install

          U3d::Commands.local_install(
            args: ['1.2.3f4'],
            options: {}
          )
        end

        #   force reinstall a discovered version -> installed (not yet implemented)
        #   TODO: Implement me
        it 'forces reinstallation of Unity with option --force' do
          puts '      --- TODO ---'
        end
      end

      describe 'platforms with modules' do
        describe 'when Unity version is not yet installed' do
          it 'logs an error when Unity is not specified in the packages' do
            on_fake_os_not_linux
            nothing_installed
            expect_no_privileges_check

            expect(U3dCore::UI).to receive(:error) {}

            U3d::Commands.local_install(
              args: ['1.2.3f4'],
              options: {
                packages: %w[packageA packageB]
              }
            )
          end

          it 'installs specified packages and Unity when specified' do
            on_fake_os_not_linux
            nothing_installed
            expect_privileges_check

            files = double("files")
            expect(U3d::Downloader).to receive(:local_files).with(
              '1.2.3f4',
              :fakeos,
              packages: %w[Unity packageA packageB]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.local_install(
              args: ['1.2.3f4'],
              options: {
                packages: %w[Unity packageA packageB],
                installation_path: 'foo'
              }
            )
          end

          it 'installs just Unity when no packages are specified' do
            on_fake_os_not_linux
            nothing_installed
            expect_privileges_check

            files = double('files')
            expect(U3d::Downloader).to receive(:local_files).with(
              '1.2.3f4',
              :fakeos,
              packages: ['Unity']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.local_install(
              args: ['1.2.3f4'],
              options: {
                installation_path: 'foo'
              }
            )
          end

          #   TODO: Reimplement --all option
          it 'installs all available packages when --all option is used' do
            puts '      --- TODO ---'
          end
        end

        describe 'when Unity version is already installed' do
          #   add an existing editor or module to a discovered install -> skipped, no credentials asked
          it 'does not ask for credentials and does nothing when no packages are specified' do
            on_fake_os_not_linux
            are_installed([fake_installation('1.2.3f4', packages: %w[packageA packageB])])
            expect_no_privileges_check
            expect_no_download
            expect_no_install

            U3d::Commands.local_install(
              args: ['1.2.3f4'],
              options: {
                installation_path: 'foo'
              }
            )
          end

          it 'installs only uninstalled packages when packages are specified' do
            on_fake_os_not_linux
            are_installed([fake_installation('1.2.3f4', packages: ['packageA'])])
            expect_privileges_check

            files = double('files')
            expect(U3d::Downloader).to receive(:local_files).with(
              '1.2.3f4',
              :fakeos,
              packages: ['packageB']
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) {}

            U3d::Commands.local_install(
              args: ['1.2.3f4'],
              options: {
                installation_path: 'foo',
                packages: %w[packageA packageB]
              }
            )
          end

          #   force reinstall the editor + modules -> installed all (not yet implemented)
          #   TODO: Implement me
          it 'forces complete reinstallation of specified packages with option --force' do
            puts '      --- TODO ---'
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
      # fail if no file arg specified
      # fail if file arg not a file
      # FIXME: no way to specify a different log rule config right now
      # passes all lines through the log analyser with the configured (default) log rule
      #   QUESTION: EOL issue ? - what about logs from other platforms?
    end
  end
end
