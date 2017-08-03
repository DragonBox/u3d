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

require 'net/http'
require 'fileutils'
require 'filesize'
require 'u3d_core/helper'

module U3d
  # Several different utility methods
  module Utils
    # Regex to capture each part of a version string (0.0.0x0)
    CSIDL_LOCAL_APPDATA = 0x001c
    UNITY_VERSION_REGEX = /(\d+)(?:\.(\d+)(?:\.(\d+))?)?(?:(\w)(?:(\d+))?)?/

    class << self
      def get_ssl(url, redirect_limit: 10)
        raise 'Too many redirections' if redirect_limit.zero?
        response = nil
        request = nil
        uri = URI(url)
        begin
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            request = Net::HTTP::Get.new uri
            response = http.request request
          end
        rescue OpenSSL::OpenSSLError => ssl_error
          UI.error 'SSL has faced an error, you may want to check our README to fix it'
          raise ssl_error
        end

        case response
        when Net::HTTPSuccess then
          response.body
        when Net::HTTPRedirection then
          UI.verbose "Redirected to #{response['location']}"
          get_ssl(response['location'], redirect_limit: redirect_limit - 1)
        else raise "Request failed with status #{response.code}"
        end
      end

      def hashfile(file_path, blocksize: 65_536)
        require 'digest'
        raise ArgumentError, 'Not a file' unless File.file?(file_path)
        md5 = Digest::MD5.new
        File.open(file_path, 'r') do |f|
          md5 << f.read(blocksize) until f.eof?
        end
        md5.hexdigest
      end

      def ensure_dir(dir)
        FileUtils.mkpath(dir) unless File.directory?(dir)
      end

      def print_progress(current, total, started_at)
        ratio = [current.to_f / total, 1.0].min
        percent = (ratio * 100.0).round(1)
        arrow = (ratio * 20.0).floor
        time_spent = Time.now.to_i - started_at
        print("\r[")
        print('=' * [arrow - 1, 0].max)
        print('>')
        print('.' * (20 - arrow))
        print("] #{pretty_filesize(current)}/#{pretty_filesize(total)} (#{percent}% at #{pretty_filesize(current.to_f / time_spent)}/s)     ")
      end

      def print_progress_nosize(current, started_at)
        time_spent = Time.now.to_i - started_at
        print("\r>#{pretty_filesize(current)} downloaded at #{pretty_filesize(current.to_f / time_spent)}/s)    ")
      end

      def parse_unity_version(version)
        ver = UNITY_VERSION_REGEX.match(version)
        if ver.nil?
          raise ArgumentError, "Version (#{version}) does not match the Unity "\
          'version format 0.0.0x0'
        end
        [ver[1], ver[2], ver[3], ver[4], ver[5]]
      end

      def windows_local_appdata
        require 'win32api'

        windir = ' ' * 261

        getdir = Win32API.new('shell32', 'SHGetFolderPath', 'LLLLP', 'L')
        result = getdir.call(0, CSIDL_LOCAL_APPDATA, 0, 0, windir)
        raise "Unable to get Local Appdata directory, returned with value #{result}" unless result.zero?
        windir.rstrip!
        windir = File.expand_path(windir.rstrip)

        return windir if Dir.exist? windir
        raise "Local Appdata retrieved (#{windir}) is not correct"
      end

      def pretty_filesize(filesize)
        Filesize.from(filesize.round.to_s + ' B').pretty
      end
    end
  end
end
