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
  # rubocop:disable ModuleLength
  module Utils
    # Regex to capture each part of a version string (0.0.0x0)
    CSIDL_LOCAL_APPDATA = 0x001c
    UNITY_VERSION_REGEX = /(\d+)(?:\.(\d+)(?:\.(\d+))?)?(?:(\w)(?:(\d+))?)?/

    class << self
      def final_url(url, redirect_limit: 10)
        follow_redirects(url, redirect_limit: redirect_limit, http_method: :head) do |request, _response|
          request.uri.to_s
        end
      end

      # FIXME: alias deprecated
      def get_ssl(url, redirect_limit: 10, request_headers: {})
        page_content(url, redirect_limit: redirect_limit, request_headers: request_headers)
      end

      def page_content(url, redirect_limit: 10, request_headers: {})
        follow_redirects(url, redirect_limit: redirect_limit, request_headers: request_headers) do |_request, response|
          response.body
        end
      end

      def follow_redirects(url, redirect_limit: 10, http_method: :get, request_headers: {}, &block)
        raise 'Too many redirections' if redirect_limit.zero?
        response = nil
        request = nil
        uri = URI(url)
        begin
          use_ssl = /^https/.match(url)
          Net::HTTP.start(uri.host, uri.port, http_opts(use_ssl: use_ssl)) do |http|
            request = http_request_class http_method, uri
            request_headers.each do |k, v|
              request[k] = v
            end
            response = http.request request
          end
        rescue OpenSSL::OpenSSLError => ssl_error
          UI.error 'SSL has faced an error, you may want to check our README to fix it'
          raise ssl_error
        end

        case response
        when Net::HTTPSuccess then
          yield(request, response)
        when Net::HTTPRedirection then
          UI.verbose "Redirected to #{response['location']}"
          follow_redirects(response['location'], redirect_limit: redirect_limit - 1, http_method: http_method, request_headers: request_headers, &block)
        else raise "Request failed with status #{response.code}"
        end
      end

      def http_request_class(method, uri)
        return Net::HTTP::Get.new uri if method == :get
        return Net::HTTP::Head.new uri if method == :head
        raise "Unknown method #{method}"
      end

      # size a hint of the expected size
      def download_file(path, url, size: nil)
        File.open(path, 'wb') do |f|
          uri = URI(url)
          current = 0
          last_print_update = 0
          print_progress = UI.interactive? || U3dCore::Globals.verbose?
          Net::HTTP.start(uri.host, uri.port, http_opts(use_ssl: uri.scheme == 'https')) do |http|
            request = Net::HTTP::Get.new uri
            http.request request do |response|
              begin
                # override with actual results, this should help with
                # innacurrate declared sizes, especially on Windows platform
                size = Integer(response['Content-Length'])
              rescue ArgumentError
                UI.verbose 'Unable to get length of file in download'
              end
              started_at = Time.now.to_i - 1
              response.read_body do |segment|
                f.write(segment)
                current += segment.length
                # wait for Net::HTTP buffer on slow networks
                # FIXME revisits, this slows down download on fast network
                # sleep 0.08 # adjust to reduce CPU
                next unless print_progress
                print_progress_now = Time.now.to_f - last_print_update > 0.5
                # force printing when done downloading
                print_progress_now = true if !print_progress_now && size && current >= size
                next unless print_progress_now
                last_print_update = Time.now.to_f
                Utils.print_progress(current, size, started_at)
                print "\n" unless UI.interactive?
              end
            end
          end
          print "\n" if print_progress
        end
      end

      def get_url_content_length(url)
        UI.verbose "get_url_content_length #{url}"
        uri = URI(url)
        size = nil
        Net::HTTP.start(uri.host, uri.port, http_opts) do |http|
          response = http.request_head url
          size = Integer(response['Content-Length'])
        end
        UI.verbose "get_url_content_length #{url}: #{size}"
        size
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

      def get_write_access(dir)
        if U3dCore::Helper.operating_system == :win
          yield
        else
          owner, access = U3dCore::CommandExecutor.execute(command: "stat -f \"%Su,%A\" #{dir}", admin: false).strip.split(',')
          current_user = U3dCore::CommandExecutor.execute(command: 'whoami', admin: false)
          U3dCore::CommandExecutor.execute(command: "chown #{current_user}: #{dir}", admin: true)
          U3dCore::CommandExecutor.execute(command: "chmod u+w #{dir}", admin: true)
          begin
            yield
          ensure
            U3dCore::CommandExecutor.execute(command: "chown #{owner}: #{dir}", admin: true)
            U3dCore::CommandExecutor.execute(command: "chmod #{access} #{dir}", admin: true)
          end
        end
      end

      # if total is nil (unknown, falls back to print_progress_nosize)
      def print_progress(current, total, started_at)
        if total.nil?
          print_progress_nosize(current, started_at)
          return
        end
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
        windir = windir.encode("UTF-8", Encoding.find('filesystem'))
        windir = File.expand_path(windir.rstrip)

        return windir if Dir.exist? windir
        raise "Local Appdata retrieved (#{windir}) is not correct"
      end

      def pretty_filesize(filesize)
        Filesize.from(filesize.round.to_s + ' B').pretty
      end

      def windows_path(path)
        UI.deprecated("Use U3dCore::Helper.windows_path")
        U3dCore::Helper.windows_path(path)
      end

      # Ruby implementation of binutils strings
      def strings(path)
        min = 4
        Enumerator.new do |y|
          File.open(path, "rb") do |f|
            s = ""
            f.each_char do |c|
              if c =~ /[[:print:]]/ # is there a cleaner way to do this check?
                s += c
                next
              else
                y.yield s if s.length >= min
                s = ""
              end
            end
            y.yield s if s.length >= min
          end
        end
      end

      private

      def http_max_retries
        ENV['U3D_HTTP_MAX_RETRIES'].to_i if ENV['U3D_HTTP_MAX_RETRIES']
      end

      def http_read_timeout
        return ENV['U3D_HTTP_READ_TIMEOUT'].to_i if ENV['U3D_HTTP_READ_TIMEOUT']
        300
      end

      def http_opts(opt = {})
        # the keys are #ca_file, #ca_path, cert, #cert_store, ciphers, #close_on_empty_response, key, #open_timeout,
        # #read_timeout, #ssl_timeout, #ssl_version, use_ssl, #verify_callback, #verify_depth and verify_mode
        opt[:max_retries] = http_max_retries if http_max_retries
        opt[:read_timeout] = http_read_timeout if http_read_timeout
        UI.verbose "Using http opts: #{opt}"
        opt
      end
    end
  end
  # rubocop:enable ModuleLength
end
