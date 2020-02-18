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

require 'u3d_core'

require 'u3d/utils'
require 'u3d/version'

require 'u3d/asset'
require 'u3d/cache'
require 'u3d/commands'
require 'u3d/commands_generator'
require 'u3d/download_validator'
require 'u3d/downloader'
require 'u3d/failure_reporter'
require 'u3d/ini_modules_parser'
require 'u3d/installation'
require 'u3d/installer'
require 'u3d/hub_modules_parser'
require 'u3d/log_analyzer'
require 'u3d/unity_license'
require 'u3d/unity_module'
require 'u3d/unity_project'
require 'u3d/unity_runner'
require 'u3d/unity_version_definition'
require 'u3d/unity_version_number'
require 'u3d/unity_versions'

module U3d
  Helper = U3dCore::Helper
  UI = U3dCore::UI

  def self.const_missing(const_name)
    deprecated = {
      PlaybackEngineUtils: IvyPlaybackEngineUtils
    }
    super unless deprecated.keys.include? const_name
    replacement = deprecated[const_name]
    UI.deprecated "DEPRECATION WARNING: the class U3d::#{const_name} is deprecated. Use #{replacement} instead."
    replacement
  end
end
