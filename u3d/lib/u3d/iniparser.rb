require 'inifile'
require 'u3d/utils'

module U3d
  # Load and parse INI files
  module INIparser
    #####################################################
    # @!group INI parameters to load and save ini files
    #####################################################
    INI_NAME_MAC = 'unity-%s-osx.ini'.freeze
    INI_NAME_WIN = 'unity-%s-win.ini'.freeze
    INI_PATH = "#{ENV['HOME']}/.u3d/ini_files".freeze

    class << self
      def load_ini(version, cached_versions)
        unless cached_versions[version]
          raise ArgumentError, "Version #{version} is not in cache"
        end
        ini_name = INI_NAME_MAC % version
        Utils.ensure_dir(INI_PATH)
        ini_path = File.expand_path(ini_name, INI_PATH)
        unless File.file?(ini_path)
          uri = URI(cached_versions[version] + ini_name)
          File.open(ini_path, 'w') do |f|
            f.write(Net::HTTP.get(uri))
          end
        end
        IniFile.load(ini_path).to_h
      end
    end
  end
end
