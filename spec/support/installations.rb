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
  allow(unity).to receive(:path) { '/Applications/Unity/Unity.app' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  return unity
end

def macinstall_5_6_custom_with_space
  unity = double("MacInstallation")
  allow(unity).to receive(:path) { '/Applications/Unity 5.6.0f1/Unity.app' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  return unity
end

def linux_5_6_standard
  unity = double("LinuxInstallation")
  allow(unity).to receive(:path) { '/opt/unity-editor-5.6.0f1' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  return unity
end

def linux_2017_1_weird
  unity = double("LinuxInstallation")
  allow(unity).to receive(:path) { '/opt/unity-editor-2017.1.0xf3Linux' }
  allow(unity).to receive(:version) { '2017.1.0f3' }
  return unity
end

def windows_5_6_32bits_default
  unity = double("WindowsInstallation")
  allow(unity).to receive(:path) { 'C:/Program Files (x86)/Unity' }
  allow(unity).to receive(:version) { '5.6.0f1' }
  return unity
end

def windows_2017_1_64bits_renamed
  unity = double("WindowsInstallation")
  allow(unity).to receive(:path) { 'C:/Program Files/Unity_2017.1.0f3' }
  allow(unity).to receive(:version) { '2017.1.0f3' }
  return unity
end
