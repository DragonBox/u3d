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

require 'rexml/document'

module U3d
  class License
    attr_reader :path

    def initialize(path: nil, fields: nil)
      @path = path
      @fields = fields || {}
    end

    def [](index)
      @fields[index]
    end

    # petit cachotier va!
    def number
      require 'base64'
      Base64.decode64(self['DeveloperData'])[4..-1]
    end

    class << self
      LICENSES_DIR_MAC = File.join("/", "Library", "Application Support", "Unity").freeze
      LICENSES_DIR_WINDOWS = File.join("C:/ProgramData", "Unity").freeze
      LICENSES_DIR_LINUX = File.join(ENV['HOME'], ".local", "share", "unity3d", "Unity").freeze

      def from_path(path)
        doc = REXML::Document.new(File.read(path))
        fields = {}
        license = REXML::XPath.first(doc, "root/License")
        unless license.nil?
          fields = []
          license.each_element_with_attribute("Value") do |e|
            fields << [e.name, e.attribute('Value').to_s]
          end
        end
        License.new(path: path, fields: fields.to_h)
      end

      def licenses
        glob = File.join(licenses_dir, "*.ulf")
        Dir.glob(glob).map do |path|
          from_path(path)
        end
      end

      def licenses_dir
        return LICENSES_DIR_MAC if U3d::Helper.mac?
        return LICENSES_DIR_WINDOWS if U3d::Helper.windows?
        return LICENSES_DIR_LINUX if U3d::Helper.linux?
      end
    end
  end
end
