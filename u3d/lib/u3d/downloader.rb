require 'net/http'
require 'u3d/iniparser'
require 'u3d/utils'

module U3d
  # Take care of downloading files and packages
  # Mac OSX support only at the moment
  module Downloader
    RELEASE_LETTERS = { 'release' => 'f', 'patch' => 'p' }.freeze
    RELEASE_LETTER_STRENGTH = { 'f' => 1, 'p' => 2, 'b' => 3, 'a' => 4 }.freeze

    # Name of the directory for the package downloading
    DOWNLOAD_DIRECTORY = 'Unity_Packages'.freeze
    # Path to the directory for the package downloading
    DOWNLOAD_PATH = "#{ENV['HOME']}/Downloads".freeze
    # Regex to get the name of a package out of its file name
    UNITY_PACKAGE_FILE_REGEX = %r{\w+\/(.+\.pkg)}

    class << self
      # Downloads all packages available for given version
      def download_all(version, cached_versions)
        if cached_versions[version].nil?
          UI.error "No version #{version} was found in cache. It might need updating."
          return nil
        end
        files = []
        ini_file = INIparser.load_ini(version, cached_versions)
        ini_file.keys.each do |k|
          files << download_specific(k, version, cached_versions)
        end
        files
      end

      # Downloads a specific package for given version
      def download_specific(package, version, cached_versions)
        if cached_versions[version].nil?
          UI.error "No version #{version} was found in cache. It might need updating."
          return nil
        end

        ini_file = INIparser.load_ini(version, cached_versions)
        if ini_file[package].empty?
          UI.error "No package \"#{package}\" was found for version #{version}."
          return nil
        end

        url = cached_versions[version]
        dir = File.join(DOWNLOAD_PATH, DOWNLOAD_DIRECTORY, version)
        Utils.ensure_dir(dir)
        get_package(package, ini_file, dir, url)
      end

      private #-----------------------------------------------------------------

      def get_package(name, ini_file, main_dir, base_url)
        file_name = UNITY_PACKAGE_FILE_REGEX.match(ini_file[name]['url'])[1]
        file_path = File.expand_path(file_name, main_dir)
        if File.file?(file_path)
          if File.size?(file_path) == ini_file[name]['size'] && Utils.hashfile(file_path) == ini_file[name]['md5']
            UI.important "File is already downloaded at #{file_path}"
            return file_path
          else
            UI.important "File at #{file_path} looks corrupted, deleting it"
            File.delete(file_path)
          end
        end
        url = base_url + ini_file[name]['url']
        UI.header "Downloading #{name}"
        UI.verbose 'Downloading from ' + url.to_s.cyan.underline
        download_package(file_path, url, ini_file[name]['size'])
        unless Utils.hashfile(file_path) == ini_file[name]['md5']
          File.delete(file_path)
          raise 'Download failed: file is corrupted, deleting it.'
        end
        UI.success "Successfully downloaded #{name}."
        file_path
      end

      def download_package(path, url, size)
        File.open(path, 'wb') do |f|
          uri = URI(url)
          current = 0
          Net::HTTP.start(uri.host, uri.port) do |http|
            request = Net::HTTP::Get.new uri
            http.request request do |response|
              response.read_body do |segment|
                f.write(segment)
                current += segment.length
                Utils.print_progress(current, size)
              end
            end
          end
          print "\n"
        end
      end
    end
  end
end
