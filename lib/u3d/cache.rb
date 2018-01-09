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

require 'json'
require 'time'
require 'u3d_core/core_ext/operating_system_symbol'
require 'u3d/unity_versions'
require 'u3d/utils'

module U3d
  # Cache stores the informations regarding versions
  class Cache
    using ::CoreExtensions::OperatingSystem

    # Path to the directory containing the cache for the different OS
    DEFAULT_LINUX_PATH = File.join(ENV['HOME'], '.u3d').freeze
    DEFAULT_MAC_PATH = File.join(ENV['HOME'], 'Library', 'Application Support', 'u3d').freeze
    DEFAULT_WINDOWS_PATH = File.join(ENV['HOME'], 'AppData', 'Local', 'u3d').freeze
    # Name of the file itself
    DEFAULT_NAME = 'cache.json'.freeze
    # Maximum duration after which the cache is considered outdated
    # Currently set to 24h
    CACHE_LIFE = 60 * 60 * 24

    GLOBAL_CACHE_URL = 'https://dragonbox.github.io/unities/v1/versions.json'.freeze

    private

    attr_accessor :cache

    public

    attr_accessor :path

    def [](key)
      return nil if @cache[key].nil?
      @cache[key]
    end

    def initialize(path: nil, force_os: nil, force_refresh: false, offline: false, central_cache: false)
      raise "Cache: cannot specify both offline and force_refresh" if offline && force_refresh
      @path = path || Cache.default_os_path
      @cache = {}
      os = force_os || U3dCore::Helper.operating_system
      Utils.ensure_dir(@path)
      file_path = File.expand_path(DEFAULT_NAME, @path)
      need_update, data = check_for_update(file_path, os)
      if offline
        UI.verbose("Cache outdated but we are working offline, so no updating it.")
        need_update = false
      end
      @cache = data
      overwrite_cache(file_path, os, central_cache: central_cache) if need_update || force_refresh
    end

    def self.default_os_path
      case U3dCore::Helper.operating_system
      when :linux
        DEFAULT_LINUX_PATH
      when :mac
        DEFAULT_MAC_PATH
      when :win
        DEFAULT_WINDOWS_PATH
      end
    end

    private #-------------------------------------------------------------------

    # Checks if the cache needs updating
    def check_for_update(file_path, os)
      need_update = false
      data = {}
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
          need_update = os_data_need_update?(data, os)
          data[os.id2name] = nil if need_update
        end
      end
      return need_update, data
    end

    def os_data_need_update?(data, os)
      data[os.id2name].nil?\
      || data[os.id2name]['lastupdate'].nil?\
      || (Time.now.to_i - data[os.id2name]['lastupdate'] > CACHE_LIFE)\
      || (data[os.id2name]['versions'] || []).empty?
    end

    # Updates cache by retrieving versions with U3d::Downloader
    def overwrite_cache(file_path, os, central_cache: false)
      update_cache(os) unless central_cache && fetch_central_cache(os)

      File.delete(file_path) if File.file?(file_path)
      File.open(file_path, 'w') { |f| f.write(@cache.to_json) }
    end

    # Fetches central versions.json. Ignore it if it is too old
    def fetch_central_cache(os)
      UI.message("Fetching central 'versions.json' cache")
      data = JSON.parse(Utils.get_ssl(GLOBAL_CACHE_URL))
      need_update = os_data_need_update?(data, os)
      @cache = data unless need_update
      !need_update
    rescue StandardError => e
      UI.error("Failed fetching central versions.json. Manual fetch for platform #{os} #{e}")
      false
    end

    def update_cache(os)
      UI.important "Cache is out of date. Updating cache for #{os.human_name}"

      @cache ||= {}
      @cache[os.id2name] = {}
      @cache[os.id2name]['lastupdate'] = Time.now.to_i
      @cache[os.id2name]['versions'] = UnityVersions.list_available(os: os)
    end
  end
end
