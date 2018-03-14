require 'date'
require 'fileutils'
require 'json'

module U3d
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
      end

      def default_report_path
        File.join(U3dCore::Helper.data_path, 'failures')
      end
    end
  end
end
