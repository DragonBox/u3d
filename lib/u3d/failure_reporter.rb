require 'date'
require 'fileutils'
require 'json'

module U3d
  # Internal class to use when trying to improve the prettifier
  # Opt-in with env variable U3D_REPORT_FAILURES
  class FailureReporter
    class << self
      def report(failure_type: "DEFAULT", failure_message: "", data: {})
        return unless ENV['U3D_REPORT_FAILURES']
        report = {
          type: failure_type,
          message: failure_message,
          data: data
        }

        FileUtils.mkdir_p default_report_path
        report_file = File.join(
          default_report_path,
          "#{failure_type}.#{Date.now.strftime('%Y%m%dT%H%M')}.failure.json"
        )

        File.open(report_file, 'w') do |file|
          file.write JSON.pretty_generate(report)
        end

      rescue StandardError => e
        UI.important "Unable to report a #{failure_type} failure. Please use --verbose to get more information about the failure"
        UI.verbose "Unable to report failure: #{e}"
        UI.verbose "Failure was: [#{failure_type}]: #{failure_message}"
      end

      def default_report_path
        File.join(U3dCore::Helper.data_path, 'failures')
      end
    end
  end
end
