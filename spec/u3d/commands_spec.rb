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
    describe "#list_installed" do
      # 0 version installed -> display message
      # 1 version, without option packages -> only version
      # multiple versions, with or without option packages, sorted
      # 1 version, with option packages -> also packages
      # when we support a specific version number (e.g. to list the packages of that version)
      #   request a non existing version number -> fail
      #   request an existing version number -> only that version
    end
    describe "#list_available" do
      describe 'common' do
        it 'raises an error when specifying an invalid operating system' do
          expect { U3d::Commands.list_available(options: {:operating_system => 'NotAnOs' }) }.to raise_error StandardError
        end
      end

      describe 'when loading from cache' do

      end


      # common
      #   force refresh -> cache refreshed
      #   request a non existing version number -> fail
      #   request an existing version number -> only that version
      #   platform: validate, fail, use the specified one, or current as fallback
      # list from cache
      #   in proper order
      #   filter those from the release type if specified
      #   display packages if specified
      #     make sure this works properly on Linux support with our fake INI file
    end

    describe "#download" do
      describe 'common' do
        #   no version specified -> look for version in current project folder if any
        describe 'when no version is specified' do
          it 'fetches the version of the project in the current folder' do
            in_a_project '1.2.3f4'
            on_fake_os
            with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })

            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              anything
            )
            U3d::Commands.download(
              args: [],
              options: {
                no_install: true,
                packages: [ 'Unity' ]
              }
            ) { [] }
          end

          it 'raises an error if not in a project folder' do
            not_in_a_project

            expect {
              U3d::Commands.download(
                args: [],
                options: {
                  no_install: true,
                  packages: [ 'Unity' ]
                }
              )
            }.to raise_error U3dCore::Interface::UIError
          end
        end

        #   request an aliased version -> resolve alias
        it 'resolves alias when passed as a version' do
          on_fake_os
          with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })

          expect(U3d::Downloader).to receive(:download_modules).with(
            '1.2.3f4',
            { '1.2.3f4' => 'fakeurl' },
            :fakeos,
            anything
          )
          U3d::Commands.download(
            args: [ 'latest' ],
            options: {
              no_install: true,
              packages: [ 'Unity' ]
            }
          )
        end

        #   request a non existing version number -> fail
        #   QUESTION: Raises an error instead of logging?
        it 'logs an error when specifying a non existing version' do
          on_fake_os
          with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })

          expect(U3dCore::UI).to receive(:error) { }

          U3d::Commands.download(
            args: [ 'not.a.version' ],
            options: {
              no_install: true,
              packages: [ 'Unity' ]
            }
          )
        end

        #   cache is outdated -> cache refreshed
        #   NOTE: This shoudln't be tested by Commands, but by Cache

        #   support downloading the not current platform -> not yet supported
        #   TODO: Imlement me

        #   support installing multiple versions at once -> not yet supported
        #   TODO: Implement me
      end

      describe 'platforms without modules' do
        #   install a non discovered version -> installed
        it 'installs Unity when version is not yet present' do
          on_linux
          with_fake_cache({ 'linux' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })
          expect_privileges_check

          files = double("files")
          expect(U3d::Downloader).to receive(:download_modules) { files }

          expect(U3d::Installer).to receive(:install_modules).with(
            files,
            '1.2.3f4',
            installation_path: 'foo'
          ) { }

          U3d::Commands.download(
            args: [ '1.2.3f4' ],
            options: {
              installation_path: 'foo'
            }
          )
        end

        #   reinstall a discovered version -> skipped, no credentials asked
        it 'does not ask for credentials and does nothing when version is already present' do
          on_linux
          with_fake_cache({ 'linux' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })
          are_installed([ fake_linux('1.2.3f4') ])
          expect_no_privileges_check
          expect_no_download
          expect_no_install

          U3d::Commands.download(
            args: [ '1.2.3f4' ],
            options: { }
          )
        end

        #   force reinstall a discovered version -> installed (not yet implemented)
        #   TODO: Implement me
        it 'forces reinstallation of Unity with option --force' do
          puts '      --- TODO ---'
        end
      end

      describe 'platforms with modules' do
        describe 'when Unity version is already installed' do

        end

        describe 'when Unity version is not yet installed' do
          it 'logs an error when Unity is not specified in the packages' do
            on_fake_os_not_linux
            with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })
            nothing_installed
            expect_no_privileges_check

            expect(U3dCore::UI).to receive(:error) { }

            U3d::Commands.download(
              args: [ '1.2.3f4' ],
              options: {
                packages: [ 'packageA', 'packageB' ]
              }
            )
          end

          it 'installs specified packages and Unity when specified' do
            on_fake_os_not_linux
            with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })
            nothing_installed
            expect_privileges_check

            files = double("files")
            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              packages: [ 'Unity', 'packageA', 'packageB' ]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) { }

            U3d::Commands.download(
              args: [ '1.2.3f4' ],
              options: {
                packages: [ 'Unity', 'packageA', 'packageB' ],
                installation_path: 'foo'
              }
            )
          end

          it 'installs just Unity when no packages are specified' do
            on_fake_os_not_linux
            with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })
            nothing_installed
            expect_privileges_check

            files = double("files")
            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              packages: [ 'Unity' ]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) { }

            U3d::Commands.download(
              args: [ '1.2.3f4' ],
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
            with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })
            are_installed([fake_installation('1.2.3f4', packages: [ 'packageA', 'packageB' ]) ])
            expect_no_privileges_check
            expect_no_download
            expect_no_install

            U3d::Commands.download(
              args: [ '1.2.3f4' ],
              options: {
                installation_path: 'foo'
              }
            )
          end

          it 'installs only uninstalled packages when packages are specified' do
            on_fake_os_not_linux
            with_fake_cache({ 'fakeos' => { 'versions' => { '1.2.3f4' => 'fakeurl' } } })
            are_installed([fake_installation('1.2.3f4', packages: [ 'packageA' ]) ])
            expect_privileges_check

            files = double("files")
            expect(U3d::Downloader).to receive(:download_modules).with(
              '1.2.3f4',
              { '1.2.3f4' => 'fakeurl' },
              :fakeos,
              packages: [ 'packageB' ]
            ) { files }
            expect(U3d::Installer).to receive(:install_modules).with(
              files,
              '1.2.3f4',
              installation_path: 'foo'
            ) { }

            U3d::Commands.download(
              args: [ '1.2.3f4' ],
              options: {
                installation_path: 'foo',
                packages: [ 'packageA', 'packageB' ]
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
    describe "#local_install" do
      # very similar to downlad, except that we don't download.
    end
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
    describe "#prettify" do
      # fail if no file arg specified
      # fail if file arg not a file
      # FIXME: no way to specify a different log rule config right now
      # passes all lines through the log analyser with the configured (default) log rule
      #   QUESTION: EOL issue ? - what about logs from other platforms?
    end
  end
end
