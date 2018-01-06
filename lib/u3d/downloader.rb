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

require 'u3d/utils'
require 'u3d/download_validator'

module U3d
  # Take care of downloading files and packages
  module Downloader
    # Name of the directory for the package downloading
    DOWNLOAD_DIRECTORY = 'Unity_Packages'.freeze
    # Path to the directory for the package downloading
    DOWNLOAD_PATH = "#{ENV['HOME']}/Downloads".freeze
    # Regex to get the name of a package out of its file name
    UNITY_MODULE_FILE_REGEX = %r{\/([\w\-_\.\+]+\.(?:pkg|exe|zip|sh|deb))}

    class << self
      def download_directory
        File.expand_path(ENV['U3D_DOWNLOAD_PATH'] || File.join(DOWNLOAD_PATH, DOWNLOAD_DIRECTORY))
      end

      # fetch modules and put them in local cache
      def fetch_modules(definition, packages: [], download: nil)
        if download
          download_modules(definition, packages: packages)
        else
          local_files(definition, packages: packages)
        end
      end

      # download packages
      def download_modules(definition, packages: [])
        files = []
        validator, downloader = setup_os(definition.os)

        packages.each do |package|
          get_package(downloader, validator, package, definition, files)
        end
        files
      end

      # find already downloaded packages
      def local_files(definition, packages: [])
        files = []
        validator, downloader = setup_os(definition.os)

        packages.each do |package|
          path = downloader.destination_for(package, definition)
          if File.file?(path)
            if validator.validate(package, path, definition)
              files << [package, path, definition[package]]
            else
              UI.important "File present at #{path} is not correct, will not be used. Skipping #{package}"
            end
          else
            UI.error "No file has been downloaded for #{package}, or it has been moved from #{path}"
          end
        end

        files
      end

      private #-----------------------------------------------------------------

      def setup_os(os)
        case os
        when :linux
          validator = LinuxValidator.new
          downloader = Downloader::LinuxDownloader.new
        when :mac
          validator = MacValidator.new
          downloader = Downloader::MacDownloader.new
        when :win
          validator = WindowsValidator.new
          downloader = Downloader::WindowsDownloader.new
        else
          raise ArgumentError, "Operating system #{os.id2name} is not recognized"
        end
        return validator, downloader
      end

      def get_package(downloader, validator, package, definition, files)
        path = downloader.destination_for(package, definition)
        url = downloader.url_for(package, definition)
        if File.file?(path)
          UI.verbose "Installer file for #{package} seems to be present at #{path}"
          if validator.validate(package, path, definition)
            UI.message "#{package.capitalize} is already downloaded"
            files << [package, path, definition[package]]
            return
          else
            extension = File.extname(path)
            new_path = File.join(File.dirname(path), File.basename(path, extension) + '_CORRUPTED' + extension)
            UI.important "File present at #{path} is not correct, it has been renamed to #{new_path}"
            File.rename(path, new_path)
          end
        end

        UI.header "Downloading #{package} version #{definition.version}"
        UI.message 'Downloading from ' + url.to_s.cyan.underline
        UI.message 'Download will be found at ' + path
        download_package(path, url, size: definition.size_in_bytes(package))

        if validator.validate(package, path, definition)
          UI.success "Successfully downloaded #{package}."
          files << [package, path, definition[package]]
        else
          UI.error "Failed to download #{package}"
        end
      end

      def download_package(path, url, size: nil)
        Utils.download_file(path, url, size: size)
      rescue Interrupt => e
        # Ensure that the file is deleted if download is aborted
        File.delete path
        raise e
      end
    end

    class MacDownloader
      def destination_for(package, definition)
        dir = File.join(Downloader.download_directory, definition.version)
        Utils.ensure_dir(dir)
        file_name = UNITY_MODULE_FILE_REGEX.match(definition[package]['url'])[1]

        File.expand_path(file_name, dir)
      end

      def url_for(package, definition)
        definition.url + definition[package]['url']
      end
    end

    class LinuxDownloader
      def destination_for(package, definition)
        dir = File.join(Downloader.download_directory, definition.version)
        Utils.ensure_dir(dir)
        file_name = UNITY_MODULE_FILE_REGEX.match(definition[package]['url'])[1]

        File.expand_path(file_name, dir)
      end

      def url_for(_package, definition)
        definition.url
      end
    end

    class WindowsDownloader
      def destination_for(package, definition)
        dir = File.join(Downloader.download_directory, definition.version)
        Utils.ensure_dir(dir)
        file_name = UNITY_MODULE_FILE_REGEX.match(definition[package]['url'])[1]

        File.expand_path(file_name, dir)
      end

      def url_for(package, definition)
        definition.url + definition[package]['url']
      end
    end
  end
end
