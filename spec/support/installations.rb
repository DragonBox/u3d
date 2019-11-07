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

# various fake installs
def macinstall_5_6_default
  unity = double("MacInstallation")
  # allow(unity).to receive(:path) { '/Applications/Unity/Unity.app' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  allow(unity).to receive(:build_number) { 'bf5cca3e2788' }
  allow(unity).to receive(:clean_install?) { false }
  allow(unity).to receive(:root_path) { '/Applications/Unity' }
  return unity
end

def macinstall_5_6_custom_location
  unity = double("MacInstallation")
  # allow(unity).to receive(:path) { '/Applications/Unity/Unity.app' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  allow(unity).to receive(:build_number) { 'bf5cca3e2788' }
  allow(unity).to receive(:clean_install?) { false }
  allow(unity).to receive(:root_path) { '/tmp/Applications/Unity' }
  return unity
end

def macinstall_5_6_custom_with_space
  unity = double("MacInstallation")
  # allow(unity).to receive(:path) { '/Applications/Unity 5.6.0f1/Unity.app' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  allow(unity).to receive(:build_number) { 'bf5cca3e2788' }
  allow(unity).to receive(:clean_install?) { false }
  allow(unity).to receive(:root_path) { '/Applications/Unity 5.6.0f1' }
  return unity
end

def linux_5_6_standard
  unity = double("LinuxInstallation")
  # allow(unity).to receive(:path) { '/opt/unity-editor-5.6.0f1' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  allow(unity).to receive(:build_number) { 'bf5cca3e2788' }
  allow(unity).to receive(:clean_install?) { true }
  allow(unity).to receive(:root_path) { '/opt/unity-editor-5.6.0f1' }
  return unity
end

def linux_5_6_debian
  unity = double("LinuxInstallation")
  # allow(unity).to receive(:path) { '/opt/Unity' }
  allow(unity).to receive(:version) { '5.6.0f2' }
  allow(unity).to receive(:build_number) { 'a7535b2c1eb6' }
  allow(unity).to receive(:clean_install?) { false }
  allow(unity).to receive(:root_path) { '/opt/Unity' }
  return unity
end

def linux_2017_1_weird
  unity = double("LinuxInstallation")
  # allow(unity).to receive(:path) { '/opt/unity-editor-2017.1.0xf3Linux' }
  allow(unity).to receive(:version) { '2017.1.0f3' }
  allow(unity).to receive(:build_number) { '061bcf22327f' }
  allow(unity).to receive(:clean_install?) { false }
  allow(unity).to receive(:root_path) { '/opt/unity-editor-2017.1.0xf3Linux' }
  return unity
end

def windows_5_6_32bits_default
  unity = double("WindowsInstallation")
  # allow(unity).to receive(:path) { 'C:/Program Files (x86)/Unity' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  allow(unity).to receive(:build_number) { 'bf5cca3e2788' }
  allow(unity).to receive(:root_path) { 'C:/Program Files (x86)/Unity' }
  return unity
end

def windows_2017_1_64bits_renamed
  unity = double("WindowsInstallation")
  # allow(unity).to receive(:path) { 'C:/Program Files/Unity_2017.1.0f3' }
  allow(unity).to receive(:version) { '2017.1.0f3' }
  allow(unity).to receive(:build_number) { '472613c02cf7' }
  allow(unity).to receive(:root_path) { 'C:/Program Files/Unity_2017.1.0f3' }
  return unity
end

def windows_2017_1_64bits_custom_location
  unity = double("WindowsInstallation")
  # allow(unity).to receive(:path) { 'C:/Program Files/Unity_2017.1.0f3' }
  allow(unity).to receive(:version) { '2017.1.0f3' }
  allow(unity).to receive(:build_number) { '472613c02cf7' }
  allow(unity).to receive(:root_path) { 'E:/Program Files/Unity_2017.1.0f3' }
  return unity
end

def fake_linux(version)
  unity = double("LinuxInstallation")
  allow(unity).to receive(:version) { version }
  allow(unity).to receive(:build_number) { 'build_number' }
  allow(unity).to receive(:root_path) { 'foo' }
  allow(unity).to receive(:packages) { false }
  return unity
end

def fake_installation(version, packages: [], do_not_move: false)
  unity = double("Installation")
  allow(unity).to receive(:version) { version }
  allow(unity).to receive(:build_number) { 'build_number' }
  allow(unity).to receive(:root_path) { 'foo' }
  allow(unity).to receive(:packages) { packages }
  allow(unity).to receive(:do_not_move?) { do_not_move }
  allow(unity).to receive(:package_installed?) { |arg| packages.include?(arg) }
  return unity
end
