require "u3d_core"
require "credentials_manager"

module U3d
  class Options
    def self.available_run_options
      @run_options ||= run_options
    end

    def self.run_options
      [
        U3dCore::ConfigItem.new(key: :unity_version,
                                     short_option: "-u",
                                     env_name: "U3D_VERSION",
                                     optional: true,
                                     description: "Version of Unity to run with",
                                     conflicting_options: [:unity_install],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can only pass either a 'unity_install' or a '#{value.key}', not both")
                                     end),
        U3dCore::ConfigItem.new(key: :unity_install,
                                     env_name: "U3D_INSTALL",
                                     optional: true,
                                     description: "Installation path of the Unity version to run with",
                                     conflicting_options: [:unity_version],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can only pass either a 'unity_version' or a '#{value.key}', not both")
                                     end)

      ]
    end
  end
end
