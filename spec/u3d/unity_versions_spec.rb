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
    def fake_linux_ini_data(size, url)
      { 'Unity' => { 'title' => 'Unity', 'size' => size, 'url' => url } }
    end

    describe '.list_available' do
      it 'retrieves windows versions' do
        allow(U3d::Utils).to receive(:get_ssl) { windows_archive }
        expect(U3d::UnityVersions.list_available(os: :win).count).to eql 3
      end
      it 'retrieves mac versions' do
        allow(U3d::Utils).to receive(:get_ssl) { macosx_archive }
        expect(U3d::UnityVersions.list_available(os: :mac).count).to eql 3
      end

      context "Linux support" do
        before(:each) do
          @unity_forums = double("UnityForums")
          U3d::UnityVersions::LinuxVersions.unity_forums = @unity_forums
        end

        def with_forum_page(content)
          paginations_urls = [ 'https://forums_page_1' ]
          allow(@unity_forums).to receive(:pagination_urls) { paginations_urls }
          allow(@unity_forums).to receive(:page_content).with(paginations_urls[0]) { content } # main page
        end


        it 'retrieves standard linux versions' do
          with_forum_page(linux_archive)
          allow(U3d::Utils).to receive(:get_url_content_length).with(/download.un.*1.2.3f1/) { 1005 }
          allow(U3d::Utils).to receive(:get_url_content_length).with(/download.un.*1.3.5f1/) { 1006 }
          allow(U3d::Utils).to receive(:get_url_content_length).with(/download.un.*2017.1.6f1/) { 1007 }

          expect(U3d::UnityVersionDefinition).to receive(:create_fake).with('1.2.3f1', 1005, /download.un.*1.2.3f1/)
          expect(U3d::UnityVersionDefinition).to receive(:create_fake).with('1.3.5f1', 1006, /download.un.*1.3.5f1/)
          expect(U3d::UnityVersionDefinition).to receive(:create_fake).with('2017.1.6f1', 1007, /download.un.*2017.1.6f1/)
          expect(U3d::UnityVersions.list_available(os: :linux).count).to eql 3
        end

        it 'doesn\'t retrieves standard linux versions if their size are already cached' do
          with_forum_page(linux_archive)
          allow(U3d::INIparser).to receive(:load_ini).with('1.2.3f1', nil, os: :linux, offline: true) { fake_linux_ini_data(1005, 'something 1.2.3f1') }
          allow(U3d::INIparser).to receive(:load_ini).with('1.3.5f1', nil, os: :linux, offline: true) { fake_linux_ini_data(1006, 'something 1.3.5f1') }
          allow(U3d::INIparser).to receive(:load_ini).with('2017.1.6f1', nil, os: :linux, offline: true) { fake_linux_ini_data(1007, 'something 2017.1.6f1') }
          expect(U3d::UnityVersionDefinition).to_not receive(:create_fake)
          expect(U3d::UnityVersions.list_available(os: :linux).count).to eql 3
        end

        it 'retrieves nested linux versions' do
          with_forum_page(linux_nested_archive)
          allow(@unity_forums).to receive(:page_content).with('http://beta.unity3d.com/download/b515b8958382/public_download.html') { linux_inner_archive }

          allow(U3d::INIparser).to receive(:load_ini).with('1.2.3f1', nil, os: :linux, offline: true) { fake_linux_ini_data(1005, 'something 1.2.3f1') }
          allow(U3d::INIparser).to receive(:load_ini).with('1.3.5f1', nil, os: :linux, offline: true) {}
          allow(U3d::Utils).to receive(:get_url_content_length).with(/download.un.*1.3.5f1/) { 1006 }
          allow(U3d::INIparser).to receive(:load_ini).with('2017.1.6f1', nil, os: :linux, offline: true) { fake_linux_ini_data(1007, 'something 1.2.3f1') }
          allow(U3d::INIparser).to receive(:load_ini).with('2017.1.0b3', nil, os: :linux, offline: true) {}
          allow(U3d::Utils).to receive(:get_url_content_length).with(/beta.un.*b515b8958382/) { 1008 }
          expect(U3d::UnityVersionDefinition).to receive(:create_fake).with('1.3.5f1', 1006, /download.un.*1.3.5f1/)
          expect(U3d::UnityVersionDefinition).to receive(:create_fake).with('2017.1.0b3', 1008, /beta.un.*b515b8958382/)
          expect(U3d::UnityVersions.list_available(os: :linux).count).to eql 4
        end
      end
    end
  end
end
