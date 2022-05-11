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

require 'u3d/ini_modules_parser'

module U3d
  class UnityVersionDefinition
    attr_accessor :version, :os, :url
    attr_reader :packages

    private

    attr_writer :packages

    public

    def initialize(version, os, cached_versions, offline: false)
      @version = version
      @os = os
      # Cache is assumed to be correct
      @url = cached_versions ? cached_versions[version] : nil
      @packages = UnityModule.load_modules(version, cached_versions, os: os, offline: offline)
    end

    def available_packages
      @packages.map(&:id)
    end

    def available_package?(package)
      available_packages.include? package.downcase
    end

    def [](package)
      return nil unless available_package? package

      @packages.find { |pack| pack.id == package.downcase }
    end

    def ini
      UI.deprecated 'UnityVersionDefinition no longer exposes the raw ini data'
      return nil
    end

    def ini=(_value)
      UI.deprecated 'UnityVersionDefinition no longer exposes the raw ini data'
    end
  end
end
