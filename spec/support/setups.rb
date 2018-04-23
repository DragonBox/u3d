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
## --- END LICENSE BLOCK ---#

# various fake setups
def on_mac
  allow(U3d::Helper).to receive(:mac?) { true }
  allow(U3d::Helper).to receive(:linux?) { false }
  allow(U3d::Helper).to receive(:windows?) { false }
  allow(U3d::Helper).to receive(:operating_system) { :mac }
end

def on_linux
  allow(U3d::Helper).to receive(:operating_system) { :linux }
  allow(U3d::Helper).to receive(:mac?) { false }
  allow(U3d::Helper).to receive(:linux?) { true }
  allow(U3d::Helper).to receive(:windows?) { false }
end

def on_windows
  allow(U3d::Helper).to receive(:mac?) { false }
  allow(U3d::Helper).to receive(:linux?) { false }
  allow(U3d::Helper).to receive(:windows?) { true }
  allow(U3d::Helper).to receive(:operating_system) { :win }
end

def on_fake_os
  allow(U3d::Helper).to receive(:operating_system) { :fakeos }
end

def on_fake_os_not_linux
  allow(U3d::Helper).to receive(:operating_system) { :fakeos }
  allow(U3d::Helper).to receive(:linux?) { false }
end

def are_installed(installations)
  double_installer(installations)
end

def nothing_installed
  double_installer
end

def double_installer(installations = [])
  installer = double("Installer")
  allow(U3d::Installer).to receive(:create) { installer }
  allow(installer).to receive(:installed) { installations }
  installer
end

def expect_privileges_check
  expect(U3dCore::CommandExecutor).to receive(:has_admin_privileges?) { true }
end

def expect_no_privileges_check
  expect(U3dCore::CommandExecutor).to_not receive(:has_admin_privileges?) { false }
end

def expect_no_download
  expect(U3d::Downloader).to_not receive(:download_modules)
end

def expect_no_install
  expect(U3d::Installer).to_not receive(:install_modules)
end

def in_a_project(version: nil, path: nil)
  project = double("UnityProject")
  allow(U3d::UnityProject).to receive(:new) { project }
  allow(project).to receive(:path) { path }
  allow(project).to receive(:exist?) { true }
  allow(project).to receive(:editor_version) { version }
end

def not_in_a_project
  project = double("UnityProject")
  allow(U3d::UnityProject).to receive(:new) { project }
  allow(project).to receive(:exist?) { false }
end

def with_fake_cache(cache)
  allow(U3d::Cache).to receive(:new) { cache }
end

def expected_definition(version, os, url, packages: [])
  allow(U3d::INIparser).to receive(:load_ini).with(version, anything, anything) do
    ini = {}
    packages.each { |pack| ini[pack] = {} }
    ini
  end
  if url
    definition = U3d::UnityVersionDefinition.new(version, os, version => url)
    expect(U3d::UnityVersionDefinition).to receive(:new).with(version, os, hash_including(version => url)) { definition }
  else
    definition = U3d::UnityVersionDefinition.new(version, os, nil)
    expect(U3d::UnityVersionDefinition).to receive(:new).with(version, os, anything) { definition }
  end
  definition
end

def mock_version_definition(version: '0.0.0x0', os: :fakeos, ini: nil)
  allow(U3d::INIparser).to receive(:load_ini).with(version, anything, anything) { ini }
  definition = U3d::UnityVersionDefinition.new(version, os, nil)
  definition
end
