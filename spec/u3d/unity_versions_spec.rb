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

    describe ".list_available integration tests" do
      xit 'retrieves the versions we expect' do
        # expect(U3d::UnityVersions.list_available(os: :win).count).to be > 200
        # expect(U3d::UnityVersions.list_available(os: :mac).count).to be > 200
        # ['2017.3.1p2'].each do |missing|
        #  expect(U3d::UnityVersions.list_available(os: :mac).keys).to include(missing)
        # end
        ['2017.2.1f1', '2017.3.1f1', '2018.1.0b8'].each do |missing|
          expect(U3d::UnityVersions.list_available(os: :linux).keys).to include(missing)
        end
      end
    end

    describe '.list_available' do
      it 'retrieves windows versions' do
        expect(U3d::Utils).to receive(:get_ssl) { "" } # lts
        expect(U3d::Utils).to receive(:get_ssl) { windows_archive }
        expect(U3d::Utils).to receive(:get_ssl).at_least(2).times { "" }
        expect(U3d::UnityVersions.list_available(os: :win).count).to eql 3
      end
      it 'retrieves mac versions' do
        expect(U3d::Utils).to receive(:get_ssl) { "" } # lts
        expect(U3d::Utils).to receive(:get_ssl) { macosx_archive }
        expect(U3d::Utils).to receive(:get_ssl).at_least(2).times { "" }
        expect(U3d::UnityVersions.list_available(os: :mac).count).to eql 3
      end

      context "Linux support" do
        before(:each) do
          @unity_forums = double("UnityForums")
          U3d::UnityVersions::LinuxVersions.unity_forums = @unity_forums
        end

        def with_forum_page(content)
          paginations_urls = ['https://forums_page_1']
          allow(@unity_forums).to receive(:pagination_urls) { paginations_urls }
          allow(@unity_forums).to receive(:page_content).with(paginations_urls[0]) { content } # main page
        end

        it 'retrieves standard linux versions' do
          with_forum_page(linux_archive_old)
          allow(U3d::Utils).to receive(:get_url_content_length).with(/download.un.*1.2.3f1/) { 1005 }
          allow(U3d::Utils).to receive(:get_url_content_length).with(/download.un.*1.3.5f1/) { 1006 }
          allow(U3d::Utils).to receive(:get_url_content_length).with(/download.un.*2017.1.6f1/) { 1007 }

          expect(U3d::UnityVersions.list_available(os: :linux).keys).to eql ['1.2.3f1', '1.3.5f1', '2017.1.6f1']
        end

        it 'retrieves nested and packaged linux versions' do
          with_forum_page(linux_archive_all)
          allow(@unity_forums).to receive(:page_content).with('http://beta.unity3d.com/download/b515b8958382/public_download.html') { linux_public_archive_standalone }
          allow(@unity_forums).to receive(:page_content).with('http://beta.unity3d.com/download/3c89f8d277f5/public_download.html') { linux_public_archive_assistant }
          allow(@unity_forums).to receive(:page_content).with('https://beta.unity3d.com/download/ce9f6a0436e1+/public_download.html') { linux_public_archive_standalone_plus }

          allow(U3d::INIparser).to receive(:load_ini).with('1.2.3f1', nil, os: :linux, offline: true) { fake_linux_ini_data(1005, 'something 1.2.3f1') }
          allow(U3d::INIparser).to receive(:load_ini).with('1.3.5f1', nil, os: :linux, offline: true) {}
          allow(U3d::INIparser).to receive(:load_ini).with('2017.1.6f1', nil, os: :linux, offline: true) { fake_linux_ini_data(1007, 'something 1.2.3f1') }
          allow(U3d::INIparser).to receive(:load_ini).with('2017.1.0b3', nil, os: :linux, offline: true) {}
          allow(U3d::INIparser).to receive(:load_ini).with('2017.3.0f1', nil, os: :linux, offline: true) {}
          allow(U3d::INIparser).to receive(:load_ini).with('2017.2.1f1', nil, os: :linux, offline: true) {}

          expect(U3d::UnityVersions.list_available(os: :linux).keys).to eql ['1.2.3f1', '1.3.5f1', '2017.1.6f1', '2018.3.0f2', '2017.1.0b3', '2017.3.0f1', '2017.2.1f1']
        end
      end
    end
  end
end
