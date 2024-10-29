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

module U3d
  class UnityModule
    # Basic module attributes
    attr_reader :id, :name, :description, :url
    # Validation attributes
    attr_reader :installed_size, :download_size, :checksum
    # Internal attributes
    attr_reader :os, :depends_on, :command, :destination, :rename_from, :rename_to

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      id:, name: nil, description: nil, url: nil,
      installed_size: nil, download_size: nil, checksum: nil,
      os: nil, depends_on: nil, command: nil, destination: nil, rename_from: nil, rename_to: nil
    )
      @id = id.downcase
      @name = name
      @description = description
      @url = url
      @installed_size = installed_size
      @download_size = download_size
      @checksum = checksum
      @os = os
      @depends_on = depends_on
      @command = command
      @destination = destination
      @rename_from = rename_from
      @rename_to = rename_to
    end
    # rubocop:enable Metrics/ParameterLists

    def depends_on?(other)
      return true if other.id == 'unity'
      return false unless depends_on

      other.id == depends_on || other.name == depends_on
    end

    class << self
      def load_modules(version, cached_versions, os: U3dCore::Helper.operating_system, offline: false)
        if version.is_a? Array
          UI.verbose "Loading modules for several versions: #{version}"
          load_versions_modules(version, cached_versions, os, offline)
        else
          UI.verbose "Loading modules for version #{version}"
          load_version_modules(version, cached_versions, os, offline)
        end
      end

      private

      # Optimized version of load_version_modules that only makes one HTTP call
      def load_versions_modules(versions, cached_versions, os, offline)
        ini_modules = versions.to_h do |version|
          ini_data = INIModulesParser.load_ini(version, cached_versions, os: os, offline: offline)
          url_root = cached_versions[version]
          modules = ini_data.map { |k, v| module_from_ini_data(k, v, url_root, os) }
          [version, modules]
        end

        HubModulesParser.download_modules(os: os) unless offline
        hub_modules = versions.to_h do |version|
          json_data = HubModulesParser.load_modules(version, os: os, offline: true)
          modules = json_data.map { |data| module_from_json_data(data, os) }
          [version, modules]
        end

        return ini_modules.merge(hub_modules) do |_version, ini_version_modules, json_version_modules|
          (ini_version_modules + json_version_modules).uniq(&:id)
        end
      end

      def load_version_modules(version, cached_versions, os, offline)
        ini_data = INIModulesParser.load_ini(version, cached_versions, os: os, offline: offline)
        url_root = cached_versions[version]
        ini_modules = ini_data.map { |k, v| module_from_ini_data(k, v, url_root, os) }

        json_data = HubModulesParser.load_modules(version, os: os, offline: offline)
        json_modules = json_data.map { |data| module_from_json_data(data, os) }

        return (ini_modules + json_modules).uniq(&:id)
      end

      def module_from_ini_data(module_key, entries, url_root, os)
        url = entries['url']
        url = url_root + url unless /^http/ =~ url

        UnityModule.new(
          id: module_key,
          name: entries['title'],
          description: entries['description'],
          url: url,
          download_size: entries['size'],
          installed_size: entries['installedsize'],
          checksum: entries['md5'],
          command: entries['cmd'],
          depends_on: entries['sync'],
          os: os
        )
      end

      def module_from_json_data(entries, os)
        UnityModule.new(
          id: entries['id'],
          name: entries['name'],
          description: entries['description'],
          url: entries['downloadUrl'],
          download_size: entries['downloadSize'],
          installed_size: entries['installedSize'],
          checksum: entries['checksum'],
          destination: entries['destination'],
          rename_from: entries['renameFrom'],
          rename_to: entries['renameTo'],
          command: entries['cmd'],
          depends_on: entries['sync'],
          os: os
        )
      end
    end
  end
end
