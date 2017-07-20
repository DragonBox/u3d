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
