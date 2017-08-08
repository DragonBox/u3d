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
require 'u3d/iniparser'
require 'u3d/utils'

module U3d
  # Take care of downloading files and packages
  # rubocop:disable ModuleLength
  module Downloader
    # Name of the directory for the package downloading
    DOWNLOAD_DIRECTORY = 'Unity_Packages'.freeze
    # Path to the directory for the package downloading
    DOWNLOAD_PATH = "#{ENV['HOME']}/Downloads".freeze
    # Regex to get the name of a package out of its file name
    UNITY_MODULE_FILE_REGEX = %r{\/([\w\-_\.\+]+\.(?:pkg|exe|zip|sh|deb))}

    class << self
      def hash_validation(expected: nil, actual: nil)
        if expected
          if expected != actual
            UI.verbose "Expected hash is #{expected}, file hash is #{actual}"
            UI.important 'File looks corrupted (wrong hash)'
            return false
          end
        else
          UI.verbose 'No hash validation available. File is assumed correct but may not be.'
        end
        true
      end

      def size_validation(expected: nil, actual: nil)
        if expected
          if expected != actual
            UI.verbose "Expected size is #{expected}, file size is #{actual}"
            UI.important 'File looks corrupted (wrong size)'
            return false
          end
        else
          UI.verbose 'No size validation available. File is assumed correct but may not be.'
        end
        true
      end

      # download packages or all if none specified
      def download_modules(version, versions, os, packages: [])
        files = []
        if os == :linux
          downloader = Downloader::LinuxDownloader
          files << ["Unity #{version}", downloader.download(version, versions), {}]
        else
          downloader = Downloader::MacDownloader if os == :mac
          downloader = Downloader::WindowsDownloader if os == :win
          if packages.count.zero?
            files = downloader.download_all(version, versions)
          else
            packages.each do |package|
              result = downloader.download_specific(package, version, versions)
              files << [package, result[0], result[1]] unless result.nil?
            end
          end
        end
        files
      end

      # find already downloaded packages or all if none specified
      def local_files(version, os, packages: [])
        files = []
        if os == :linux
          downloader = Downloader::LinuxDownloader
          files << ["Unity #{version}", downloader.local_file(version), {}]
        else
          downloader = Downloader::MacDownloader if os == :mac
          downloader = Downloader::WindowsDownloader if os == :win
          if packages.count.zero?
            files = downloader.all_local_files(version)
          else
            packages.each do |package|
              result = downloader.local_file(package, version)
              files << [package, result[0], result[1]] unless result.nil?
            end
          end
        end
        files
      end

      def download_package(path, url, size: nil)
        File.open(path, 'wb') do |f|
          uri = URI(url)
          current = 0
          last_print_update = 0
          Net::HTTP.start(uri.host, uri.port) do |http|
            request = Net::HTTP::Get.new uri
            http.request request do |response|
              begin
                size ||= Integer(response['Content-Length'])
              rescue ArgumentError
                UI.verbose 'Unable to get length of file in download'
              end
              started_at = Time.now.to_i - 1
              response.read_body do |segment|
                f.write(segment)
                current += segment.length
                # wait for Net::HTTP buffer on slow networks
                sleep 0.08 # adjust to reduce CPU
                next unless UI.interactive?
                next unless Time.now.to_f - last_print_update > 0.5
                last_print_update = Time.now.to_f
                if size
                  Utils.print_progress(current, size, started_at)
                else
                  Utils.print_progress_nosize(current, started_at)
                end
              end
            end
          end
          print "\n" if UI.interactive?
        end
      rescue Interrupt => e
        # Ensure that the file is deleted if download is aborted
        File.delete path
        raise e
      end
    end

    class MacDownloader
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
            result = download_specific(k, version, cached_versions)
            files << [k, result[0], result[1]] unless result.nil?
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
          return [get_package(package, ini_file, dir, url), ini_file[package]]
        end

        private #---------------------------------------------------------------

        def get_package(name, ini_file, main_dir, base_url)
          file_name = UNITY_MODULE_FILE_REGEX.match(ini_file[name]['url'])[1]
          file_path = File.expand_path(file_name, main_dir)

          # Check if file already exists and validate it
          if File.file?(file_path)
            if Downloader.size_validation(expected: ini_file[name]['size'], actual: File.size(file_path)) &&
               Downloader.hash_validation(expected: ini_file[name]['md5'], actual: Utils.hashfile(file_path))
              UI.important "#{name.capitalize} already downloaded at #{file_path}"
              return file_path
            else
              UI.verbose "Deleting existing file at #{file_path}"
              File.delete(file_path)
            end
          end

          # Download file
          url = base_url + ini_file[name]['url']
          UI.header "Downloading #{name}"
          UI.verbose 'Downloading from ' + url.to_s.cyan.underline
          Downloader.download_package(file_path, url, size: ini_file[name]['size'])

          # Validation download
          if Downloader.size_validation(expected: ini_file[name]['size'], actual: File.size(file_path)) &&
             Downloader.hash_validation(expected: ini_file[name]['md5'], actual: Utils.hashfile(file_path))
            UI.success "Successfully downloaded #{name}."
          else
            File.delete(file_path)
            raise 'Download failed: file is corrupted, deleting it.'
          end

          file_path
        end

        def all_local_files(version)
          files = []
          ini_file = INIparser.load_ini(version, {}, offline: true)
          ini_file.keys.each do |k|
            result = local_file(k, version)
            files << [k, result[0], result[1]] unless result.nil?
          end
          files
        end

        def local_file(package, version)
          ini_file = INIparser.load_ini(version, {}, offline: true)
          if ini_file[package].empty?
            UI.error "No package \"#{package}\" was found for version #{version}."
            return nil
          end

          dir = File.join(DOWNLOAD_PATH, DOWNLOAD_DIRECTORY, version)
          raise "Main directory #{dir} does not exist. Nothing has been downloaded for version #{version}" unless Dir.exist?(dir)

          file_name = UNITY_MODULE_FILE_REGEX.match(ini_file[package]['url'])[1]
          file_path = File.expand_path(file_name, dir)

          unless File.file?(file_path)
            UI.error "Package #{package} has not been downloaded"
            return nil
          end

          unless Downloader.size_validation(expected: ini_file[package]['size'], actual: File.size(file_path)) &&
                 Downloader.hash_validation(expected: ini_file[package]['md5'], actual: Utils.hashfile(file_path))
            UI.error "File at #{file_path} is corrupted, deleting it"
            File.delete(file_path)
            return nil
          end

          return [file_path, ini_file[package]]
        end
      end
    end

    class LinuxDownloader
      class << self
        def download(version, cached_versions)
          if cached_versions[version].nil?
            UI.error "No version #{version} was found in cache. It might need updating."
            return nil
          end
          url = cached_versions[version]
          dir = File.join(DOWNLOAD_PATH, DOWNLOAD_DIRECTORY, version)
          Utils.ensure_dir(dir)
          file_name = UNITY_MODULE_FILE_REGEX.match(url)[1]
          file_path = File.expand_path(file_name, dir)

          # Check if file already exists
          # Note: without size or hash validation, the file is assumed to be correct
          if File.file?(file_path)
            UI.important "File already downloaded at #{file_path}"
            return file_path
          end

          # Download file
          UI.header "Downloading Unity #{version}"
          UI.verbose 'Downloading from ' + url.to_s.cyan.underline
          Downloader.download_package(file_path, url)
          U3dCore::CommandExecutor.execute(command: "chmod a+x #{file_path}")
          file_path
        end

        def local_file(version)
          dir = File.join(DOWNLOAD_PATH, DOWNLOAD_DIRECTORY, version)
          raise "Main directory #{dir} does not exist. Nothing has been downloaded for version #{version}" unless Dir.exist?(dir)
          find_cmd = "find #{dir}/ -maxdepth 2 -name '*.sh'"
          files = U3dCore::CommandExecutor.execute(command: find_cmd).split("\n")
          return files[0] unless files.empty?
          raise 'No file has been downloaded'
        end
      end
    end

    class WindowsDownloader
      class << self
        def download_all(version, cached_versions)
          if cached_versions[version].nil?
            UI.error "No version #{version} was found in cache. It might need updating."
            return nil
          end
          files = []
          ini_file = INIparser.load_ini(version, cached_versions)
          ini_file.keys.each do |k|
            result = download_specific(k, version, cached_versions)
            files << [k, result[0], result[1]] unless result.nil?
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
          return [get_package(package, ini_file, dir, url), ini_file[package]]
        end

        def all_local_files(version)
          files = []
          ini_file = INIparser.load_ini(version, {}, offline: true)
          ini_file.keys.each do |k|
            result = local_file(k, version)
            files << [k, result[0], result[1]] unless result.nil?
          end
          files
        end

        def local_file(package, version)
          ini_file = INIparser.load_ini(version, {}, offline: true)
          if ini_file[package].empty?
            UI.error "No package \"#{package}\" was found for version #{version}."
            return nil
          end

          dir = File.join(DOWNLOAD_PATH, DOWNLOAD_DIRECTORY, version)
          raise "Main directory #{dir} does not exist. Nothing has been downloaded for version #{version}" unless Dir.exist?(dir)

          file_name = UNITY_MODULE_FILE_REGEX.match(ini_file[package]['url'])[1]
          file_path = File.expand_path(file_name, dir)

          unless File.file?(file_path)
            UI.error "Package #{package} has not been downloaded"
            return nil
          end

          rounded_size = (File.size(file_path).to_f / 1024).floor
          unless Downloader.size_validation(expected: ini_file[package]['size'], actual: rounded_size) &&
                 Downloader.hash_validation(expected: ini_file[package]['md5'], actual: Utils.hashfile(file_path))
            UI.error "File at #{file_path} is corrupted, deleting it"
            File.delete(file_path)
            return nil
          end

          return [file_path, ini_file[package]]
        end

        private #---------------------------------------------------------------

        def get_package(name, ini_file, main_dir, base_url)
          file_name = UNITY_MODULE_FILE_REGEX.match(ini_file[name]['url'])[1]
          file_path = File.expand_path(file_name, main_dir)

          # Check if file already exists and validate it
          if File.file?(file_path)
            rounded_size = (File.size(file_path).to_f / 1024).floor
            if Downloader.size_validation(expected: ini_file[name]['size'], actual: rounded_size) &&
               Downloader.hash_validation(expected: ini_file[name]['md5'], actual: Utils.hashfile(file_path))
              UI.important "File already downloaded at #{file_path}"
              return file_path
            else
              UI.verbose 'Deleting existing file'
              File.delete(file_path)
            end
          end

          # Download file
          url = base_url + ini_file[name]['url']
          UI.header "Downloading #{name}"
          UI.verbose 'Downloading from ' + url.to_s.cyan.underline
          Downloader.download_package(file_path, url, size: ini_file[name]['size'] * 1024)

          # Validation download
          rounded_size = (File.size(file_path).to_f / 1024).floor
          if Downloader.size_validation(expected: ini_file[name]['size'], actual: rounded_size) &&
             Downloader.hash_validation(expected: ini_file[name]['md5'], actual: Utils.hashfile(file_path))
            UI.success "Successfully downloaded #{name}."
          else
            File.delete(file_path)
            raise 'Download failed: file is corrupted, deleting it.'
          end

          file_path
        end
      end
    end
  end
  # rubocop:enable ModuleLength
end
