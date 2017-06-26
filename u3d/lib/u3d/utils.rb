require 'net/http'
require 'fileutils'
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

      def print_progress(current, total)
        ratio = [current.to_f / total, 1.0].min
        percent = (ratio * 100.0).round(1)
        arrow = (ratio * 60.0).floor
        print("\r[")
        print('=' * [arrow - 1, 0].max)
        print('>')
        print('.' * (60 - arrow))
        print("] (#{percent}%) ")
      end

      def print_progress_nosize(current)
        print("\r>#{current} bytes downloaded.  ")
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

        windir = ' '*261

        getdir = Win32API.new('shell32', 'SHGetFolderPath', 'LLLLP', 'L')
        result = getdir.call(0, CSIDL_LOCAL_APPDATA, 0, 0, windir)
        raise RuntimeError, "Unable to get Local Appdata directory, returned with value #{result}" unless result == 0
        windir.rstrip!
        windir = File.expand_path(windir.rstrip)

        return windir if Dir.exist? windir
        raise RuntimeError, "Local Appdata retrieved (#{windir}) is not correct"
      end
    end
  end
end
