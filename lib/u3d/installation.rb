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
require 'u3d_core/admin_tools'
require 'fileutils'

module U3d
  UNITY_DIR_CHECK = /Unity_\d+\.\d+\.\d+[a-z]\d+/
  UNITY_DIR_CHECK_LINUX = /unity-editor-\d+\.\d+\.\d+[a-z]\d+\z/
  # Linux unity_builtin_extra seek position for version
  UNITY_VERSION_LINUX_POS_LE_2019 = 20
  UNITY_VERSION_LINUX_POS_GT_2019 = 48
  U3D_DO_NOT_MOVE = ".u3d_do_not_move".freeze

  class Installation
    attr_accessor :root_path

    NOT_PLAYBACKENGINE_PACKAGES = %w[Documentation StandardAssets MonoDevelop].freeze
    PACKAGE_ALIASES =
      {
        'Android' => [],
        'iOS' => ['iPhone'],
        'AppleTV' => ['tvOS'],
        'Linux' => ['StandaloneLinux'],
        'Mac' => %w[StandaloneOSXIntel StandaloneOSXIntel64 StandaloneOSX],
        'Windows' => ['StandaloneWindows'],
        'Metro' => [],
        'UWP-IL2CPP' => [],
        'Samsung-TV' => [],
        'Tizen' => [],
        'WebGL' => [],
        'Facebook-Games' => ['Facebook'],
        'Vuforia-AR' => ['UnityExtensions']
      }.freeze

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

    def packages
      false
    end

    def do_not_move?
      File.exist?(@root_path) && File.exist?(do_not_move_file_path)
    end

    def do_not_move!(dry_run: false)
      if dry_run
        UI.message "Would create '#{do_not_move_file_path}'"
      else
        begin
          FileUtils.touch do_not_move_file_path
        rescue Errno::EACCES => _e
          U3dCore::AdminTools.create_file(Helper.operating_system, do_not_move_file_path)
        end
      end
    end

    def package_installed?(package)
      return true if (packages || []).include?(package)

      aliases = PACKAGE_ALIASES[package]

      # If no aliases for the package are found, then it's a new package not yet known by Unity
      # If the exact name doesn't match then we have to suppose it's not installed
      return false unless aliases

      return !(aliases & packages).empty?
    end

    private

    def do_not_move_file_path
      File.join(@root_path, U3D_DO_NOT_MOVE)
    end
  end

  class IvyPlaybackEngineUtils
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

  class ModulePlaybackEngineUtils
    def self.list_module_configs(playbackengine_parent_path)
      # this should work on all platforms, non existing paths being ignored...
      Dir.glob("#{playbackengine_parent_path}/PlaybackEngines/*/modules.asset") |
        Dir.glob("#{playbackengine_parent_path}/Unity.app/Contents/PlaybackEngines/*/modules.asset")
    end

    def self.module_name(config_path)
      File.basename(File.dirname(config_path)).gsub("Support", "")
    end
  end

  class InstallationUtils
    def self.read_version_from_unity_builtin_extra(file)
      File.open(file, "rb") do |f|
        # Check if it is version lower or equal to 2019
        seek_pos = UNITY_VERSION_LINUX_POS_LE_2019
        f.seek(seek_pos)
        z = f.read(1)
        if z == "\x00"
          # Version is greater than 2019
          seek_pos = UNITY_VERSION_LINUX_POS_GT_2019
        end
        f.seek(seek_pos)
        s = ""
        while (c = f.read(1))
          break if c == "\x00"
          s += c
        end
        s
      end
    end
  end

  class MacInstallation < Installation
    require 'plist'

    def version
      plist['CFBundleVersion']
    end

    def build_number
      plist['UnityBuildNumber']
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
      pack = []
      IvyPlaybackEngineUtils.list_module_configs(root_path).each do |mpath|
        pack << IvyPlaybackEngineUtils.module_name(mpath)
      end
      ModulePlaybackEngineUtils.list_module_configs(root_path).each do |mpath|
        pack << ModulePlaybackEngineUtils.module_name(mpath)
      end

      NOT_PLAYBACKENGINE_PACKAGES.each do |module_name|
        pack << module_name unless Dir[module_name_pattern(module_name)].empty?
      end
      pack
    end

    def module_name_pattern(module_name)
      case module_name
      when 'Documentation'
        return "#{root_path}/Documentation/"
      when 'StandardAssets'
        return "#{root_path}/Standard Assets/"
      when 'MonoDevelop'
        return "#{root_path}/MonoDevelop.app/"
      else
        UI.crash! "No pattern is known for #{module_name} on Mac"
      end
    end

    def clean_install?
      do_not_move? || !(root_path =~ UNITY_DIR_CHECK).nil?
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

  class LinuxInstallationHelper
    STRINGS_FULL_VERSION_MATCHER = /^[0-9\.abfp]+_[0-9a-f]{12}/

    def find_build_number(root)
      known_rev_locations.each do |p|
        rev = find_build_number_in("#{root}#{p}")
        return rev if rev
      end
      nil
    end

    private

    def strings(path)
      if `which strings` != ''
        binutils_strings(path)
      else
        Utils.strings(path).to_a
      end
    end

    def binutils_strings(path)
      command = "strings #{path.shellescape}"
      `#{command}`.split("\n")
    end

    # sorted by order of speed to fetch the strings data
    def known_rev_locations
      ['/Editor/BugReporter/unity.bugreporter',
       '/Editor/Data/PlaybackEngines/WebGLSupport/BuildTools/lib/UnityNativeJs/UnityNative.js.mem',
       '/Editor/Data/PlaybackEngines/LinuxStandaloneSupport/Variations/linux32_headless_nondevelopment_mono/LinuxPlayer',
       '/Editor/Unity']
    end

    def find_build_number_in(path = nil)
      return nil unless File.exist? path
      str = strings(path)
      lines = str.select { |l| l =~ STRINGS_FULL_VERSION_MATCHER }
      lines.empty? ? nil : lines[0].split('_')[1]
    end
  end

  class LinuxInstallation < Installation
    def version
      path = "#{root_path}/Editor/Data/Resources/unity_builtin_extra"
      InstallationUtils.read_version_from_unity_builtin_extra(path)
    end

    def build_number
      @build_number ||= LinuxInstallationHelper.new.find_build_number(root_path)
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
      path = "#{root_path}/Editor/Data/"
      pack = []
      IvyPlaybackEngineUtils.list_module_configs(path).each do |mpath|
        pack << IvyPlaybackEngineUtils.module_name(mpath)
      end
      ModulePlaybackEngineUtils.list_module_configs(root_path).each do |mpath|
        pack << ModulePlaybackEngineUtils.module_name(mpath)
      end
      NOT_PLAYBACKENGINE_PACKAGES.each do |module_name|
        pack << module_name unless Dir[module_name_pattern(module_name)].empty?
      end
      pack
    end

    def module_name_pattern(module_name)
      # FIXME: we are not yet sure where these modules will end up yet
      case module_name
      when 'Documentation'
        return "#{root_path}/Editor/Data/Documentation/"
      when 'StandardAssets'
        return "#{root_path}/Editor/Standard Assets/"
      when 'MonoDevelop'
        return "#{root_path}/MonoDevelop/"
      else
        UI.crash! "No pattern is known for #{module_name} on Linux"
      end
    end

    def clean_install?
      do_not_move? || !(root_path =~ UNITY_DIR_CHECK_LINUX).nil?
    end
  end

  class WindowsInstallationHelper
    def initialize(exe_path)
      @exe_path = exe_path
    end

    def version
      s = unity_version_info
      if s
        a = s.split("_")
        return a[0] unless a.empty?
      end
      nil
    end

    def build_number
      s = unity_version_info
      if s
        a = s.split("_")
        return a[1] if a.count > 1
      end
      nil
    end

    private

    def unity_version_info
      @uvf ||= string_file_info('Unity Version', @exe_path)
    end

    def string_file_info(info, path)
      require "Win32API"
      get_file_version_info_size = Win32API.new('version.dll', 'GetFileVersionInfoSize', 'PP', 'L')
      get_file_version_info = Win32API.new('version.dll', 'GetFileVersionInfo', 'PIIP', 'I')
      ver_query_value = Win32API.new('version.dll', 'VerQueryValue', 'PPPP', 'I')
      rtl_move_memory = Win32API.new('kernel32.dll', 'RtlMoveMemory', 'PLL', 'I')

      file = path.tr("/", "\\")

      buf = [0].pack('L')
      version_size = get_file_version_info_size.call(file + "\0", buf)
      raise Exception if version_size.zero? # TODO: use GetLastError

      version_info = 0.chr * version_size
      version_ok = get_file_version_info.call(file, 0, version_size, version_info)
      raise Exception if version_ok.zero? # TODO: use GetLastError

      # hardcoding lang codepage
      struct_path = "\\StringFileInfo\\040904b0\\#{info}"

      addr = [0].pack('L')
      size = [0].pack('L')
      query_ok = ver_query_value.call(version_info, struct_path + "\0", addr, size)
      raise Exception if query_ok.zero?

      raddr = addr.unpack('L')[0]
      rsize = size.unpack('L')[0]

      info = Array.new(rsize, 0).pack('L*')
      rtl_move_memory.call(info, raddr, info.length)
      info.strip
    rescue StandardError => e
      UI.verbose("Failure to find '#{info}' under '#{path}': #{e}")
      UI.verbose(e.backtrace)
      nil
    end
  end

  class WindowsInstallation < Installation
    def version
      version = helper.version
      return version unless version.nil?

      path = "#{root_path}/Editor/Data/"
      package = IvyPlaybackEngineUtils.list_module_configs(path).first
      raise "Couldn't find a module under #{path}" unless package
      IvyPlaybackEngineUtils.unity_version(package)
    end

    def build_number
      helper.build_number
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
      IvyPlaybackEngineUtils.list_module_configs(path).each do |mpath|
        pack << IvyPlaybackEngineUtils.module_name(mpath)
      end
      ModulePlaybackEngineUtils.list_module_configs(root_path).each do |mpath|
        pack << ModulePlaybackEngineUtils.module_name(mpath)
      end
      NOT_PLAYBACKENGINE_PACKAGES.each do |module_name|
        pack << module_name unless Dir[module_name_pattern(module_name)].empty?
      end
      pack
    end

    def module_name_pattern(module_name)
      case module_name
      when 'Documentation'
        return "#{root_path}/Editor/Data/Documentation/"
      when 'StandardAssets'
        return "#{root_path}/Editor/Standard Assets/"
      when 'MonoDevelop'
        return "#{root_path}/MonoDevelop/"
      else
        UI.crash! "No pattern is known for #{module_name} on Windows"
      end
    end

    def clean_install?
      do_not_move? || !(root_path =~ UNITY_DIR_CHECK).nil?
    end

    private

    def helper
      @helper ||= WindowsInstallationHelper.new(exe_path)
    end
  end
end
