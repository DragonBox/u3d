## --- BEGIN LICENSE BLOCK ---
# Copyright (c) 2017-present WeWantToKnow AS
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

require "shellwords"
require "u3d"
require "u3d/commands_generator"

module Fastlane
  module Actions
    class U3dAction < Action
      def self.run(params)
        options = params._values
        run_args = Shellwords.split(options.delete(:run_args))
        # fastlane adds its own timestamping
        ::U3dCore::Globals.log_timestamps = false
        ::U3d::Commands.run(options: options, run_args: run_args)
      end

      def self.description
        "Fastgame's u3d (a Unity3d CLI) integration"
      end

      def self.authors
        ["Jerome Lacoste"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Allows to invoke the various u3d functions from within a Fastlane project."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :unity_version,
                                  env_name: "U3D_VERSION",
                               description: "Unity version",
                                  optional: true,
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :run_args,
          #                       env_name: "U3D_YOUR_OPTION",
                               description: "U3d run arguments",
                                  optional: false,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
