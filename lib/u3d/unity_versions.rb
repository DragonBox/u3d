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

require 'u3d/iniparser'
require 'u3d_core/helper'
require 'net/http'

module U3d
  # Takes care of fectching versions and version list
  module UnityVersions
    #####################################################
    # @!group URLS: Locations to fetch information from
    #####################################################
    # URL for the forum thread listing all the Linux releases
    UNITY_LINUX_DOWNLOADS = 'https://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/'.freeze
    # URL for the main releases for Windows and Macintosh
    UNITY_DOWNLOADS = 'https://unity3d.com/get-unity/download/archive'.freeze
    # URL for the patch releases for Windows and Macintosh
    UNITY_PATCHES = 'https://unity3d.com/unity/qa/patch-releases'.freeze
    # URL for the beta releases list, they need to be accessed after
    UNITY_BETAS = 'https://unity3d.com/unity/beta/archive'.freeze
    # URL for a specific beta, takes into parameter a version string (%s)
    UNITY_BETA_URL = 'https://unity3d.com/unity/beta/unity%s'.freeze

    #####################################################
    # @!group REGEX: expressions to interpret data
    #####################################################
    # Captures a version and its base url
    MAC_DOWNLOAD = %r{"(https?://[\w/\.-]+/[0-9a-f]{12}/)MacEditorInstaller/[a-zA-Z0-9/\.]+-(\d+\.\d+\.\d+\w\d+)\.?\w+"}
    WIN_DOWNLOAD = %r{"(https?://[\w/\.-]+/[0-9a-f]{12}/)Windows..EditorInstaller/[a-zA-Z0-9/\.]+-(\d+\.\d+\.\d+\w\d+)\.?\w+"}
    LINUX_DOWNLOAD_DATED = %r{"(https?://[\w/\._-]+/unity\-editor\-installer\-(\d+\.\d+\.\d+\w\d+).*\.sh)"}
    LINUX_DOWNLOAD_RECENT_PAGE = %r{"(http://beta\.unity3d\.com/download/[a-zA-Z0-9/\.]+/public_download\.html)"}
    LINUX_DOWNLOAD_RECENT_FILE = %r{'(https?://beta\.unity3d\.com/download/[a-zA-Z0-9/\.]+/unity\-editor\-installer\-(\d+\.\d+\.\d+(?:x)?\w\d+).*\.sh)'}
    # Captures a beta version in html page
    UNITY_BETAVERSION_REGEX = %r{\/unity\/beta\/unity(\d+\.\d+\.\d+\w\d+)"}
    UNITY_EXTRA_DOWNLOAD_REGEX = %r{"(https?:\/\/[\w\/.-]+\.unity3d\.com\/(\w+))\/[a-zA-Z\/.-]+\/download.html"}

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

      def fetch_betas(url, pattern)
        hash = {}
        data = Utils.get_ssl(url)
        results = data.scan(UNITY_BETAVERSION_REGEX).uniq
        results.each { |beta| hash.merge!(fetch_version(UNITY_BETA_URL % beta[0], pattern)) }
        hash
      end
    end

    class LinuxVersions
      class << self
        def list_available
          UI.message 'Loading Unity releases'

          data = linux_forum_page_content

          data.gsub(/[ \t]+/, '').each_line { |l| puts l if /<a href=/ =~ l }
          versions = {}
          results = data.scan(LINUX_DOWNLOAD_DATED)
          results.each do |capt|
            save_package_size(capt[1], capt[0])
            versions[capt[1]] = capt[0]
          end

          response = nil
          results = data.scan(LINUX_DOWNLOAD_RECENT_PAGE)
          results.each do |page|
            url = page[0]
            uri = URI(url)
            Net::HTTP.start(uri.host, uri.port) do |http|
              request = Net::HTTP::Get.new uri
              response = http.request request
            end
            if response.is_a? Net::HTTPSuccess
              capt = response.body.match(LINUX_DOWNLOAD_RECENT_FILE)
              if capt && capt[1] && capt[2]
                ver = capt[2].delete('x')
                UI.important "Version #{ver} does not match standard Unity versions" unless ver =~ Utils::UNITY_VERSION_REGEX
                save_package_size(ver, capt[1])
                versions[ver] = capt[1]
              else
                UI.error("Could not retrieve a fitting file from #{url}")
              end
            else
              UI.error("Could not access #{url}")
            end
          end
          if versions.count.zero?
            UI.important 'Found no releases'
          else
            UI.success "Found #{versions.count} releases."
          end
          versions
        end

        def save_package_size(version, url)
          uri = URI(url)
          size = nil
          Net::HTTP.start(uri.host, uri.port) do |http|
            response = http.request_head url
            size = Integer(response['Content-Length'])
          end
          if size
            INIparser.create_linux_ini(version, size)
          else
            UI.important "u3d tried to get the size of the installer for version #{version}, but wasn't able to"
          end
        end

        def linux_forum_page_content
          response = nil
          data = ''
          uri = URI(UNITY_LINUX_DOWNLOADS)
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            request = Net::HTTP::Get.new uri
            request['Connection'] = 'keep-alive'
            response = http.request request

            case response
            when Net::HTTPSuccess then
              # Successfully retrieved forum content
              data = response.body
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
              Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http_api|
                request = Net::HTTP::Get.new uri
                request['Connection'] = 'keep-alive'
                res = http_api.request request
              end

              raise 'Unexpected result' unless res.is_a? Net::HTTPRedirection
              # It should be a redirection to the forum to perform authentication
              uri = URI(res['location'])

              request = Net::HTTP::Get.new uri
              request['Connection'] = 'keep-alive'
              request['Cookie'] = cookie_str

              res = http.request request

              raise 'Unable to establish a session with Unity forum' unless res.is_a? Net::HTTPRedirection

              cookie_str << '; ' + res['set-cookie'].gsub(/\s+/, '').split(';', 2)[0]

              uri = URI(res['location'])

              request = Net::HTTP::Get.new uri
              request['Connection'] = 'keep-alive'
              request['Cookie'] = cookie_str

              res = http.request request

              data = res.body if res.is_a? Net::HTTPSuccess
            else raise "Request failed with status #{response.code}"
            end
          end
          data
        end
      end
    end

    class MacVersions
      class << self
        def list_available
          versions = {}
          UI.message 'Loading Unity releases'
          current = UnityVersions.fetch_version(UNITY_DOWNLOADS, MAC_DOWNLOAD)
          UI.success "Found #{current.count} releases." if current.count.nonzero?
          versions = versions.merge(current)
          UI.message 'Loading Unity patch releases'
          current = UnityVersions.fetch_version(UNITY_PATCHES, MAC_DOWNLOAD)
          UI.success "Found #{current.count} patch releases." if current.count.nonzero?
          versions = versions.merge(current)
          UI.message 'Loading Unity beta releases'
          current = UnityVersions.fetch_betas(UNITY_BETAS, MAC_DOWNLOAD)
          UI.success "Found #{current.count} beta releases." if current.count.nonzero?
          versions = versions.merge(current)
          versions
        end
      end
    end

    class WindowsVersions
      class << self
        def list_available
          versions = {}
          UI.message 'Loading Unity releases'
          current = UnityVersions.fetch_version(UNITY_DOWNLOADS, WIN_DOWNLOAD)
          UI.success "Found #{current.count} releases." if current.count.nonzero?
          versions = versions.merge(current)
          UI.message 'Loading Unity patch releases'
          current = UnityVersions.fetch_version(UNITY_PATCHES, WIN_DOWNLOAD)
          UI.success "Found #{current.count} patch releases." if current.count.nonzero?
          versions = versions.merge(current)
          UI.message 'Loading Unity beta releases'
          current = UnityVersions.fetch_betas(UNITY_BETAS, WIN_DOWNLOAD)
          UI.success "Found #{current.count} beta releases." if current.count.nonzero?
          versions = versions.merge(current)
          versions
        end
      end
    end
  end
end
