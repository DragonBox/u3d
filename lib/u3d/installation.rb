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

module U3d
  UNITY_DIR_CHECK = /Unity_\d+\.\d+\.\d+[a-z]\d+/
  UNITY_DIR_CHECK_LINUX = /unity-editor-\d+\.\d+\.\d+[a-z]\d+\z/

  class Installation
    attr_reader :root_path

    def initialize(root_path: nil, path: nil)
      @root_path = root_path
      @path = path
    end

    def self.create(root_path: nil, path: nil)
      UI.deprecated("path is deprecated. Use root_path instead") unless path.nil?
      if Helper.mac?
        MacInstallation.new(root_path: root_path, path: path)
      elsif Helper.linux?
        LinuxInstallation.new(root_path: root_path, path: path)
      else
        WindowsInstallation.new(root_path: root_path, path: path)
      end
    end
  end

  class PlaybackEngineUtils
    def self.list_module_configs(playbackengine_parent_path)
      Dir.glob("#{playbackengine_parent_path}/PlaybackEngines/*/ivy.xml")
    end

    def self.node_value(config_path, node_name)
      require 'rexml/document'
      UI.verbose("reading #{config_path}")
      raise "File not found at #{config_path}" unless File.exist? config_path
      doc = REXML::Document.new(File.read(config_path))
      REXML::XPath.first(doc, node_name).value
    end

    def self.module_name(config_path)
      node_value(config_path, 'ivy-module/info/@module')
    end

    def self.unity_version(config_path)
      node_value(config_path, 'ivy-module/info/@e:unityVersion')
    end
  end

  class MacInstallation < Installation
    require 'plist'

    def version
      plist['CFBundleVersion']
    end

    def default_log_file
      "#{ENV['HOME']}/Library/Logs/Unity/Editor.log"
    end

    def exe_path
      "#{root_path}/Unity.app/Contents/MacOS/Unity"
    end

    def path
      UI.deprecated("path is deprecated. Use root_path instead")
      return @path if @path
      "#{@root_path}/Unity.app"
    end

    def packages
      PlaybackEngineUtils.list_module_configs(root_path).map do |mpath|
        PlaybackEngineUtils.module_name(mpath)
      end
    end

    def clean_install?
      !(root_path =~ UNITY_DIR_CHECK).nil?
    end

    private

    def plist
      @plist ||=
        begin
          fpath = "#{root_path}/Unity.app/Contents/Info.plist"
          raise "#{fpath} doesn't exist" unless File.exist? fpath
          Plist.parse_xml(fpath)
        end
    end
  end

  class LinuxInstallation < Installation
    def version
      # I don't find an easy way to extract the version on Linux
      path = "#{root_path}/Editor/Data/"
      package = PlaybackEngineUtils.list_module_configs(path).first
      raise "Couldn't find a module under #{path}" unless package
      version = PlaybackEngineUtils.unity_version(package)
      if (m = version.match(/^(.*)x(.*)Linux$/))
        version = "#{m[1]}#{m[2]}"
      end
      version
    end

    def default_log_file
      "#{ENV['HOME']}/.config/unity3d/Editor.log"
    end

    def exe_path
      "#{root_path}/Editor/Unity"
    end

    def path
      UI.deprecated("path is deprecated. Use root_path instead")
      @root_path || @path
    end

    def packages
      false
    end

    def clean_install?
      !(root_path =~ UNITY_DIR_CHECK_LINUX).nil?
    end
  end

  class WindowsInstallation < Installation
    def version
      path = "#{root_path}/Editor/Data/"
      package = PlaybackEngineUtils.list_module_configs(path).first
      raise "Couldn't find a module under #{path}" unless package
      PlaybackEngineUtils.unity_version(package)
    end

    def default_log_file
      if @logfile.nil?
        begin
          loc_appdata = Utils.windows_local_appdata
          log_dir = File.expand_path('Unity/Editor/', loc_appdata)
          UI.important "Log directory (#{log_dir}) does not exist" unless Dir.exist? log_dir
          @logfile = File.expand_path('Editor.log', log_dir)
        rescue RuntimeError => ex
          UI.error "Unable to retrieve the editor logfile: #{ex}"
        end
      end
      @logfile
    end

    def exe_path
      File.join(@root_path, 'Editor', 'Unity.exe')
    end

    def path
      UI.deprecated("path is deprecated. Use root_path instead")
      @root_path || @path
    end

    def packages
	  path = "#{root_path}/Editor/Data/"
	  pack = []
      PlaybackEngineUtils.list_module_configs(path).each do |mpath|
        pack << PlaybackEngineUtils.module_name(mpath)
	  end
	  pack << 'Documentation' if has_documentation?
	  pack << 'StandardAssets' if has_standard_assets?
	  pack
	end
	
	def has_documentation?
	  has_specific_dir?("#{root_path}/Editor/Data/Documentation/", check_empty: true)
	end

	def has_standard_assets?
	  has_specific_dir?("#{root_path}/Editor/Standard Assets/", check_empty: true)  
	end
	
	def has_specific_dir?(directory, check_empty: false)
	  File.directory?(directory) && (check_empty || Dir[File.join(directory, '*')].empty?)
	end

    def clean_install?
      !(root_path =~ UNITY_DIR_CHECK).nil?
    end
  end
end
