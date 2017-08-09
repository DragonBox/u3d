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
  module INIparser
    #####################################################
    # @!group INI parameters to load and save ini files
    #####################################################
    INI_NAME = 'unity-%<version>s-%<os>s.ini'.freeze
    INI_LINUX_PATH = File.join(ENV['HOME'], '.u3d', 'ini_files').freeze
    INI_MAC_PATH = File.join(ENV['HOME'], 'Library', 'Application Support', 'u3d', 'ini_files').freeze
    INI_WIN_PATH = File.join(ENV['HOME'], 'AppData', 'Local', 'u3d', 'ini_files').freeze

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
        unless File.file?(ini_path)
          if os == 'linux'
            UI.error "No INI file for version #{version}. Try discovering the available versions with 'u3d available -f'"
            return nil
          end
          raise "INI file does not exist at #{ini_path}" if offline
          uri = URI(cached_versions[version] + ini_name)
          File.open(ini_path, 'wb') do |f|
            data = Net::HTTP.get(uri)
            data.tr!("\"", '')
            data.gsub!(/Note:.+\n/, '')
            f.write(data)
          end
        end
        begin
          result = IniFile.load(ini_path).to_h
        rescue => e
          raise "Could not parse INI data (#{e})"
        end
        result
      end

      def create_linux_ini(version, size)
        ini_name = INI_NAME % { version: version, os: 'linux' }
        Utils.ensure_dir(default_ini_path)
        ini_path = File.expand_path(ini_name, default_ini_path)
        unless File.file?(ini_path)
          File.open(ini_path, 'wb') do |f|
            f.write %Q([Unity]
; -- NOTE --
; This is not an official Unity file
; This has been created by u3d
; ----------
title=Unity
size=#{size}
)
          end
        end
      end

      private

      def default_ini_path
        case U3dCore::Helper.operating_system
        when :linux
          INI_LINUX_PATH
        when :mac
          INI_MAC_PATH
        when :win
          INI_WIN_PATH
        end
      end
    end
  end
end
