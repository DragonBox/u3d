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

require 'u3d/unity_version_definition'
require 'u3d_core/helper'
require 'net/http'

module U3d
  class UnityForums
    def pagination_urls(url)
      # hardcoded for now
      # otherwise maybe
      # # <div class="PageNav" data-page="7" data-range="2" data-start="5" data-end="9" data-last="10" data-sentinel="{{sentinel}}" data-baseurl="threads/twitter.12003/page-{{sentinel}}"
      #  <span class="pageNavHeader">Page 7 of 10</span>
      [url,
       "#{url}page-2"]
    end

    def page_content(url)
      fetch_cookie
      request_headers = { 'Connection' => 'keep-alive', 'Cookie' => @cookie }
      UI.verbose "Fetching from #{url}"
      Utils.page_content(url, request_headers: request_headers)
    end

    private

    def fetch_cookie
      UI.verbose "FetchCookie? #{@cookie}"
      return @cookie if @cookie
      cookie_str = ''
      url = 'https://forum.unity.com/forums/linux-editor.93/' # a page that triggers cookies
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new uri
        request['Connection'] = 'keep-alive'
        response = http.request request

        case response
        when Net::HTTPSuccess then
          UI.verbose "unexpected result"
        when Net::HTTPRedirection then
          # A session must be opened with the server before accessing forum
          res = nil
          cookie_str = ''
          # Store the name and value of the cookies returned by the server
          response['set-cookie'].gsub(/\s+/, '').split(',').each do |c|
            cookie_str << c.split(';', 2)[0] + '; '
          end
          cookie_str.chomp!('; ')

          # It should be the Unity register API
          uri = URI(response['location'])
          UI.verbose "Redirecting to #{uri}"
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http_api|
            request = Net::HTTP::Get.new uri
            request['Connection'] = 'keep-alive'
            res = http_api.request request
          end

          raise 'Unexpected result' unless res.is_a? Net::HTTPRedirection
          # It should be a redirection to the forum to perform authentication
          uri = URI(res['location'])
          UI.verbose "Redirecting to #{uri}"
          request = Net::HTTP::Get.new uri
          request['Connection'] = 'keep-alive'
          request['Cookie'] = cookie_str

          res = http.request request

          raise 'Unable to establish a session with Unity forum' unless res.is_a? Net::HTTPRedirection

          UI.verbose "Found cookie_str #{cookie_str}"
          cookie_str << '; ' + res['set-cookie'].gsub(/\s+/, '').split(';', 2)[0]
        end
      end
      UI.verbose "Found @cookie #{cookie_str}"
      @cookie = cookie_str
    end
  end
  # Takes care of fectching versions and version list
  module UnityVersions
    #####################################################
    # @!group URLS: Locations to fetch information from
    #####################################################
    # URL for the forum thread listing all the Linux releases
    UNITY_LINUX_DOWNLOADS = 'https://forum.unity.com/threads/unity-on-linux-release-notes-and-known-issues.350256/'.freeze
    # URL for the main releases for Windows and Macintosh
    UNITY_DOWNLOADS = 'https://unity3d.com/get-unity/download/archive'.freeze
    # URL for the LTS releases for Windows and Macintosh
    UNITY_LTSES = 'https://unity3d.com/unity/qa/lts-releases'.freeze
    # URL for the patch releases for Windows and Macintosh
    UNITY_PATCHES = 'https://unity3d.com/unity/qa/patch-releases'.freeze
    # URL for the beta releases list, they need to be accessed after
    UNITY_BETAS = 'https://unity3d.com/unity/beta/archive'.freeze
    # URL for a specific beta, takes into parameter a version string (%s)
    UNITY_BETA_URL = 'https://unity3d.com/unity/beta/unity%<version>s'.freeze
    # URL for latest releases listing (since Unity 2017.1.5f1), takes into parameter os (windows => win32, mac => darwin)
    UNITY_LATEST_JSON_URL = 'https://public-cdn.cloud.unity3d.com/hub/prod/releases-%<os>s.json'.freeze

    #####################################################
    # @!group REGEX: expressions to interpret data
    #####################################################
    # Captures a version and its base url
    LINUX_DOWNLOAD = %r{['"](https?:\/\/[\w/\.-]+/[0-9a-f\+]{12,13}\/)(.\/)?UnitySetup-(\d+\.\d+\.\d+\w\d+)['"]}

    MAC_WIN_SHADERS = %r{"(https?://[\w/\.-]+/[0-9a-f\+]{12,13}/)builtin_shaders-(\d+\.\d+\.\d+\w\d+)\.?\w+"}

    LINUX_DOWNLOAD_DATED = %r{"(https?://[\w/\._-]+/unity\-editor\-installer\-(\d+\.\d+\.\d+\w\d+).*\.sh)"}
    LINUX_DOWNLOAD_RECENT_PAGE = %r{"(https?://beta\.unity3d\.com/download/[a-zA-Z0-9/\.\+]+/public_download\.html)"}
    LINUX_DOWNLOAD_RECENT_FILE = %r{'(https?://beta\.unity3d\.com/download/[a-zA-Z0-9/\.\+]+/unity\-editor\-installer\-(\d+\.\d+\.\d+(?:x)?\w\d+).*\.sh)'}
    # Captures a beta version in html page
    UNITY_BETAVERSION_REGEX = %r{\/unity\/beta\/unity(\d+\.\d+\.\d+\w\d+)"}
    UNITY_EXTRA_DOWNLOAD_REGEX = %r{"(https?:\/\/[\w\/.-]+\.unity3d\.com\/(\w+))\/[a-zA-Z\/.-]+\/download.html"}
    # For the latest releases fetched from json
    UNITY_LATEST_JSON = %r{(https?://[\w/\.-]+/[0-9a-f\+]{12,13}/)}

    class << self
      def list_available(os: nil)
        os ||= U3dCore::Helper.operating_system

        case os
        when :linux
          return U3d::UnityVersions::LinuxVersions.list_available
        when :mac
          return U3d::UnityVersions::MacVersions.list_available
        when :win
          return U3d::UnityVersions::WindowsVersions.list_available
        else
          raise ArgumentError, "Operating system #{os} not supported"
        end
      end

      def fetch_version(url, pattern)
        hash = {}
        data = Utils.get_ssl(url)
        results = data.scan(pattern)
        results.each { |capt| hash[capt[1]] = capt[0] }
        return hash
      end

      def fetch_version_paged(url, pattern)
        U3d::Utils.get_ssl(url).scan(/\?page=\d+/).map do |page|
          fetch_version("#{url}#{page}", pattern)
        end.reduce({}, :merge)
      end

      def fetch_from_json(url, pattern)
        require 'json'
        data = Utils.get_ssl(url)
        JSON.parse(data).values.flatten.select { |b| pattern =~ b['downloadUrl'] }.map do |build|
          [build['version'], pattern.match(build['downloadUrl'])[1]]
        end.to_h
      end

      def fetch_betas(url, pattern)
        hash = {}
        data = Utils.get_ssl(url)
        results = data.scan(UNITY_BETAVERSION_REGEX).uniq
        results.each { |beta| hash.merge!(fetch_version(format(UNITY_BETA_URL, version: beta[0]), pattern)) }
        hash
      end
    end

    class LinuxVersions
      @unity_forums = U3d::UnityForums.new
      class << self
        attr_accessor :unity_forums

        def list_available
          UI.message 'Loading Unity releases'
          versions = @unity_forums.pagination_urls(UNITY_LINUX_DOWNLOADS).map do |page_url|
            list_available_from_page(@unity_forums, unity_forums.page_content(page_url))
          end.reduce({}, :merge)
          if versions.count.zero?
            UI.important 'Found no releases'
          else
            UI.success "Found #{versions.count} releases."
          end
          versions
        end

        private

        def list_available_from_page(unity_forums, data)
          versions = {}

          data.scan(LINUX_DOWNLOAD_DATED) do |capt|
            versions[capt[1]] = capt[0]
          end

          data.scan(LINUX_DOWNLOAD) do |capt|
            versions[capt[2]] = capt[0]
          end

          data.scan(LINUX_DOWNLOAD_RECENT_PAGE) do |page|
            url = page[0]
            page_body = unity_forums.page_content(url)
            capt = page_body.match(LINUX_DOWNLOAD_RECENT_FILE)
            if capt && capt[1] && capt[2]
              ver = capt[2].delete('x')
              UI.important "Version #{ver} does not match standard Unity versions" unless ver =~ Utils::UNITY_VERSION_REGEX
              versions[ver] = capt[1]
            else
              capt = page_body.match(LINUX_DOWNLOAD)
              # newer version of unity on linux support ini files
              # http://beta.unity3d.com/download/3c89f8d277f5/unity-2017.3.0f1-linux.ini
              if capt && capt[1] && capt[3]
                ver = capt[3]
                UI.verbose("Linux version #{ver}. Could not retrieve a fitting file from #{url}. Assuming ini file present")
                versions[ver] = capt[1]
              else
                UI.important("Could not retrieve a fitting file from #{url}.")
              end
            end
          end

          versions
        end
      end
    end

    class VersionsFetcher
      attr_accessor :versions

      def initialize(pattern:)
        @versions = {}
        @patterns = pattern.is_a?(Array) ? pattern : [pattern]
      end

      def fetch_some(type, url)
        UI.message "Loading Unity #{type} releases"
        total = {}
        @patterns.each do |pattern|
          current = UnityVersions.fetch_version_paged(url, pattern)
          current = UnityVersions.fetch_version(url, pattern) if current.empty?
          total.merge!(current)
        end
        UI.success "Found #{total.count} #{type} releases."
        @versions.merge!(total)
      end

      def fetch_json(os)
        UI.message 'Loading Unity latest releases'
        url = format(UNITY_LATEST_JSON_URL, os: os)
        latest = UnityVersions.fetch_from_json(url, UNITY_LATEST_JSON)

        UI.success "Found #{latest.count} latest releases."

        @versions.merge!(latest) do |key, oldval, newval|
          UI.important "Unity version #{key} already fetched, replacing #{oldval} with #{newval}" if newval != oldval
          newval
        end

        @versions
      end

      def fetch_all_channels
        fetch_some('lts', UNITY_LTSES)
        fetch_some('stable', UNITY_DOWNLOADS)
        fetch_some('patch', UNITY_PATCHES)
        # This does not work any longer
        # fetch_some('beta', UNITY_BETAS)
        @versions
      end
    end

    class MacVersions
      class << self
        def list_available
          versions_fetcher = VersionsFetcher.new(pattern: [MAC_WIN_SHADERS])
          versions_fetcher.fetch_all_channels
          versions_fetcher.fetch_json('darwin')
        end
      end
    end

    class WindowsVersions
      class << self
        def list_available
          versions_fetcher = VersionsFetcher.new(pattern: MAC_WIN_SHADERS)
          versions_fetcher.fetch_all_channels
          versions_fetcher.fetch_json('win32')
        end
      end
    end
  end
end
