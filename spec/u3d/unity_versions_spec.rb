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

require 'u3d/cache'
require 'json'
require 'time'
require 'support/download_archives'

describe U3d do
  describe U3d::UnityVersions do
    describe '.list_available' do
      it 'retrieves windows versions' do
        allow(U3d::Utils).to receive(:get_ssl) { windows_archive }
        expect(U3d::UnityVersions.list_available(os: :win).count).to eql 3
      end
      it 'retrieves mac versions' do
        allow(U3d::Utils).to receive(:get_ssl) { macosx_archive }
        expect(U3d::UnityVersions.list_available(os: :mac).count).to eql 3
      end
      it 'retrieves standard linux versions' do
        allow(U3d::UnityVersions::LinuxVersions).to receive(:linux_forum_page_content) { linux_archive }
        expect(U3d::UnityVersions.list_available(os: :linux).count).to eql 3
      end
      it 'retrieves nested linux versions' do
        allow(U3d::UnityVersions::LinuxVersions).to receive(:linux_forum_page_content) { linux_nested_archive }
        allow(U3d::UnityVersions::LinuxVersions).to receive(:linux_forum_version_page_content).with('http://beta.unity3d.com/download/b515b8958382/public_download.html') { linux_inner_archive }
        expect(U3d::UnityVersions.list_available(os: :linux).count).to eql 4
      end
    end
  end
end
