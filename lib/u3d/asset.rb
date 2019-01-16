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

require 'yaml'

module U3d
  # U3d::Asset provides you with a way to easily manipulate an search for assets in Unity Projects
  class Asset
    class << self
      def glob(pattern)
        Dir.glob(pattern).reject { |path| File.extname(path) == '.meta' || !File.file?(path) }.map { |path| Asset.new(path) }
      end
    end

    attr_accessor :path, :meta_path, :guid

    def initialize(path)
      raise "No file at #{path}" unless File.exist?(path)
      @path = path
      @meta_path = path + ".meta"
      @guid = YAML.safe_load(File.read(@meta_path))['guid']
    end

    def guid_references
      @guid_references ||= `grep -rl #{@guid} Assets/`.split("\n").reject { |f| f == @meta_path }.map { |path| Asset.new(path) }
    end

    def name_references
      @name_references ||= `grep -rl #{File.basename(@path, extension)} Assets/ --include=*.cs`.split("\n").reject { |f| f == @meta_path }.map { |path| Asset.new(path) }
    end

    def extension
      File.extname(@path)
    end

    def eql?(other)
      return false unless other.is_a? Asset
      other.guid == @guid
    end

    def hash
      @guid.to_i
    end

    def to_s
      "#{@guid}:#{@path}"
    end

    def inspect
      to_s
    end
  end
end
