module Fastlane
  module Actions
    class U3dAction < Action
      def self.run(params)
        UI.message("The u3d plugin is working!")
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
        # Optional:
        "Allows to invoke the various u3d functions from within a Fastlane project."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "U3D_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
