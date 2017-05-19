require 'inifile'
require 'u3d/utils'
require 'u3d_core/helper'

module U3d
  # Load and parse INI files
  module INIparser
    #####################################################
    # @!group INI parameters to load and save ini files
    #####################################################
    INI_NAME = 'unity-%{version}-%{os}.ini'.freeze
    INI_PATH = "#{ENV['HOME']}/.u3d/ini_files".freeze

    class << self
      def load_ini(version, cached_versions, os: U3dCore::Helper.operating_system, offline: false)
        unless os == :win || os == :mac
          raise ArgumentError, "OS #{os.id2name} does not use ini files"
        end
        if os == :mac
          os = 'osx'
        else
          os = os.id2name
        end
        ini_name = INI_NAME % { :version => version, :os => os }
        Utils.ensure_dir(INI_PATH)
        ini_path = File.expand_path(ini_name, INI_PATH)
        unless File.file?(ini_path)
          raise "INI file does not exist at #{ini_path}" if offline
          uri = URI(cached_versions[version] + ini_name)
          File.open(ini_path, 'wb') do |f|
            data = Net::HTTP.get(uri)
            data.tr!("\"", '')
            data.gsub!(/Note:.+\n/, '')
            f.write(data)
          end
        end
        IniFile.load(ini_path).to_h
      end
    end
  end
end
