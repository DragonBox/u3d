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

require 'yaml'

module U3d
  # U3d::Asset provides you with a way to easily manipulate an search for assets in Unity Projects
  class Asset
    class << self
      def glob(pattern, unity_project_path = Dir.pwd)
        unity_project = U3d::UnityProject.new(unity_project_path)
        Dir.glob(pattern).reject { |path| File.extname(path) == '.meta' || !File.file?(path) }.map { |path| Asset.new(path, unity_project) }
      end
    end

    attr_reader :path, :meta_path, :meta, :guid

    def initialize(path, unity_project = nil)
      raise ArgumentError, "No file at #{path}" unless File.exist?(path)

      @path = path
      @meta_path = "#{path}.meta"
      @meta = YAML.safe_load(File.read(@meta_path))
      @guid = @meta['guid']
      @unity_project = unity_project
    end

    def guid_references
      @guid_references ||= U3dCore::CommandExecutor.execute(
        command: "grep -rl #{@guid} #{grep_reference_root}",
        print_command: false
      ).split("\n").reject { |f| f == @meta_path }.map { |path| Asset.new(path) }
    end

    def name_references
      @name_references ||= U3dCore::CommandExecutor.execute(
        command: "grep -rl #{File.basename(@path, extension)} #{grep_reference_root} --include=*.cs",
        print_command: false
      ).split("\n").map { |path| Asset.new(path) }
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

    private

    def grep_reference_root
      @unity_project&.exist? ? 'Assets/' : '.'
    end
  end
end
