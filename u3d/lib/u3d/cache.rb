require 'json'
require 'time'
require 'u3d/unity_versions'
require 'u3d/utils'

module U3d
  # Cache stores the informations regarding versions
  class Cache
    # Path to the directory containing the cache
    DEFAULT_PATH = "#{ENV['HOME']}/.u3d".freeze
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

    def initialize(path: nil)
      @path = path || DEFAULT_PATH
      @cache = {}
      Utils.ensure_dir(@path)
      filepath = File.expand_path(DEFAULT_NAME, @path)
      need_update, data = check_for_update(filepath)
      need_update ? overwrite_cache(filepath) : @cache = data
    end

    private #-------------------------------------------------------------------

    # Checks if the cache needs updating
    def check_for_update(filepath)
      need_update = false
      data = nil
      if !File.file?(filepath)
        need_update = true
      else
        begin
          data = JSON.parse(File.open(filepath, 'r').read)
        rescue JSON::ParserError => json_error
          UI.error 'Failed to parse cache.json: ' + json_error.to_s
          need_update = true
        rescue SystemCallError => file_error
          UI.error 'Failed to open cache.json: ' + file_error.to_s
          need_update = true
        else
          need_update = data['lastupdate'].nil? || (
          Time.now.to_i - data['lastupdate'] > CACHE_LIFE)
        end
      end
      return need_update, data
    end

    # Updates cache by retrieving versions with U3d::Downloader
    def overwrite_cache(filepath)
      UI.important 'Cache is out of date. Updating cache...'
      @cache['lastupdate'] = Time.now.to_i
      @cache['versions'] = UnityVersions.list_available
      File.open(filepath, 'w') do |f|
        f.write(@cache.to_json)
      end
    end
  end
end
