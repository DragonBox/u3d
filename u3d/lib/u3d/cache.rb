require 'json'
require 'time'
require 'u3d/unity_versions'
require 'u3d/utils'

module U3d
  # Cache stores the informations regarding versions
  class Cache
    # Path to the directory containing the cache for the different OS
    DEFAULT_LINUX_PATH = File.join(ENV['HOME'], '.u3d').freeze
    DEFAULT_MAC_PATH = File.join(ENV['HOME'], 'Library', 'Application Support', 'u3d').freeze
    DEFAULT_WINDOWS_PATH = File.join(ENV['HOME'], 'AppData', 'Local', 'u3d').freeze
    # Name of the file itself
    DEFAULT_NAME = 'cache.json'.freeze
    # Maximum duration after which the cache is considered outdated
    # Currently set to 24h
    CACHE_LIFE = 60 * 60 * 24

    private

    attr_accessor :cache

    public

    attr_accessor :path

    def [](key)
      return nil if @cache[key].nil?
      @cache[key]
    end

    def initialize(path: nil, force_os: nil)
      @path = path || default_path
      @cache = {}
      os = force_os || U3dCore::Helper.operating_system
      Utils.ensure_dir(@path)
      file_path = File.expand_path(DEFAULT_NAME, @path)
      need_update, data = check_for_update(file_path, os)
      @cache = data
      overwrite_cache(file_path, os) if need_update
    end

    private #-------------------------------------------------------------------

    # Checks if the cache needs updating
    def check_for_update(file_path, os)
      need_update = false
      data = nil
      if !File.file?(file_path)
        need_update = true
      else
        begin
          File.open(file_path, 'r') do |f|
            data = JSON.parse(f.read)
          end
        rescue JSON::ParserError => json_error
          UI.error 'Failed to parse cache.json: ' + json_error.to_s
          need_update = true
        rescue SystemCallError => file_error
          UI.error 'Failed to open cache.json: ' + file_error.to_s
          need_update = true
        else
          need_update = data[os.id2name].nil?\
          || data[os.id2name]['lastupdate'].nil?\
          || (Time.now.to_i - data[os.id2name]['lastupdate'] > CACHE_LIFE)\
          || (data[os.id2name]['versions'] || []).empty?
          data[os.id2name] = nil if need_update
        end
      end
      return need_update, data
    end

    # Updates cache by retrieving versions with U3d::Downloader
    def overwrite_cache(file_path, os)
      platform = 'Windows' if os == :win
      platform = 'Mac OSX' if os == :mac
      platform = 'Linux' if os == :linux
      UI.important "Cache is out of date. Updating cache for #{platform}"
      @cache ||= {}
      @cache[os.id2name] = {}
      @cache[os.id2name]['lastupdate'] = Time.now.to_i
      @cache[os.id2name]['versions'] = UnityVersions.list_available(os: os)
      File.delete(file_path) if File.file?(file_path)
      File.open(file_path, 'w') { |f| f.write(@cache.to_json) }
    end

    def default_path
      case U3dCore::Helper.operating_system
      when :linux
        DEFAULT_LINUX_PATH
      when :mac
        DEFAULT_MAC_PATH
      when :win
        DEFAULT_WINDOWS_PATH
      end
    end
  end
end
