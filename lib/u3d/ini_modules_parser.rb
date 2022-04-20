# frozen_string_literal: true

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

require 'inifile'
require 'u3d/utils'
require 'u3d_core/helper'

module U3d
  # Load and parse INI files
  module INIModulesParser
    #####################################################
    # @!group INI parameters to load and save ini files
    #####################################################
    INI_NAME = 'unity-%<version>s-%<os>s.ini'

    class << self
      def load_ini(version, cached_versions, os: U3dCore::Helper.operating_system, offline: false)
        os = if os == :mac
               'osx'
             else
               os.id2name
             end
        ini_name = format(INI_NAME, version: version, os: os)
        Utils.ensure_dir(default_ini_path)
        ini_path = File.expand_path(ini_name, default_ini_path)
        unless File.file?(ini_path) && File.size(ini_path).positive?
          raise "INI file does not exist at #{ini_path}" if offline

          download_ini(version, cached_versions, os, ini_name, ini_path)
        end
        begin
          result = IniFile.load(ini_path).to_h
        rescue StandardError => e
          raise "Could not parse INI data (#{e})"
        end
        result
      end

      def create_linux_ini(version, size, url)
        ini_name = format(INI_NAME, version: version, os: 'linux')
        Utils.ensure_dir(default_ini_path)
        ini_path = File.expand_path(ini_name, default_ini_path)
        return if File.file?(ini_path) && File.size(ini_path).positive?

        data = %([Unity]
; -- NOTE --
; This is not an official Unity file
; This has been created by u3d
; ----------
title=Unity
size=#{size}
url=#{url}
)
        write_ini_file(ini_path, data)
      end

      private

      def download_ini(version, cached_versions, os, ini_name, ini_path)
        # former urls for Linux pointed to unity-editor-installer.sh directlry
        if os == 'linux' && cached_versions[version] =~ /.*.sh$/
          UI.verbose "No INI on server. Faking one by finding out package size for version #{version}"
          url = cached_versions[version]
          size = Utils.get_url_content_length(url)
          if size
            create_linux_ini(version, size, url)
          else
            UI.important "u3d tried to get the size of the installer for version #{version}, but wasn't able to"
          end
          return
        end
        uri = URI(cached_versions[version] + ini_name)
        UI.verbose("Searching for ini file at #{uri}")

        data = Net::HTTP.get(uri)
        data = data.tr("\"", '')
        data = data.gsub(/Note:.+\n/, '')

        write_ini_file(ini_path, data)
      end

      def write_ini_file(ini_path, data)
        File.binwrite(ini_path, data)
      end

      def default_ini_path
        File.join(U3dCore::Helper.data_path, 'ini_files')
      end
    end
  end
end
