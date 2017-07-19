module Fastlane
  module Helper
    class U3dHelper
      # class methods that you define here become available in your action
      # as `Helper::U3dHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the u3d plugin helper!")
      end
    end
  end
end
