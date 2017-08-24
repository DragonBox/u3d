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

require 'u3d/iniparser'

module U3d
  class UnityVersionDefinition
    attr_accessor :version, :os, :url, :ini

    def initialize(version, os, cached_versions)
      @version = version
      @os = os
      # Cache is assumed to be correct
      @url = cached_versions ? cached_versions[version] : nil
      begin
        @ini = INIparser.load_ini(version, cached_versions, os: os)
      rescue => e
        UI.error "Could not load INI file for version #{@version} on #{@os}: #{e}"
        @ini = nil
      end
    end

    def available_packages
      @ini.keys
    end

    def [](key)
      return nil unless @ini
      @ini[key]
    end

    def size_in_kb(package)
      return -1 unless @ini[package] && @ini[package]['size']
      @os == :win ? @ini[package]['size'] * 1024 : @ini[package]['size']
    end
  end
end
