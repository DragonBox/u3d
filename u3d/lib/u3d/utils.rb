require 'net/http'
require 'fileutils'

module U3d
  # Several different utility methods
  module Utils
    # Regex to capture each part of a version string (0.0.0x0)
    UNITY_VERSION_REGEX = /(\d+)(?:\.(\d+)(?:\.(\d+))?)?(?:(\w)(?:(\d+))?)?/

    class << self
      def get_ssl(url)
        # FIXME: not working on Windows -> Solution may be there :
        # https://gist.github.com/luislavena/f064211759ee0f806c88
        # TODO: catch exceptions
        response = nil
        uri = URI(url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          request = Net::HTTP::Get.new uri
          response = http.request request
        end
        response.body if response.code == '200'
      end

      def hashfile(file_path, blocksize: 65_536)
        require 'digest'
        raise 'Not a file' unless File.file?(file_path)
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
        ratio = current.to_f / total
        percent = (ratio * 100.0).round(1)
        arrow = (ratio * 60.0).floor
        print("\r[")
        print('=' * [arrow - 1, 0].max)
        print('>')
        print('.' * (60 - arrow))
        print("] (#{percent}%)")
      end

      def parse_unity_version(version)
        ver = UNITY_VERSION_REGEX.match(version)
        if ver.nil?
          raise ArgumentError, "Version (#{version}) does not match the Unity "\
          'version format 0.0.0x0'
        end
        [ver[1], ver[2], ver[3], ver[4], ver[5]]
      end
    end
  end
end
