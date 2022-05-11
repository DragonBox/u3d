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

require 'u3d_core/helper'

module U3d
  class UnityProject
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def exist?
      Dir.exist?(assets_path) && Dir.exist?(project_settings_path)
    end

    def assets_path
      File.join(@path, 'Assets')
    end

    def project_settings_path
      File.join(@path, 'ProjectSettings')
    end

    def editor_version
      require 'yaml'
      project_version = File.join(project_settings_path, 'ProjectVersion.txt')
      return nil unless File.exist? project_version

      yaml = YAML.safe_load(File.read(project_version))
      version = yaml['m_EditorVersion']
      version = version.gsub(/(\d+\.\d+\.\d+)(?:x)?(\w\d+)(?:Linux)?/, '\1\2') if Helper.linux?
      version
    end
  end
end
