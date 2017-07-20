## --- BEGIN LICENSE BLOCK ---
# Original work Copyright (c) 2015-present the fastlane authors
# Modified work Copyright 2016-present WeWantToKnow AS
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

require 'logger'
require 'colored'

module U3dCore
  # rubocop:disable Metrics/ModuleLength
  module Helper

    # Runs a given command using backticks (`)
    # and prints them out using the UI.command method
    def self.backticks(command, print: true)
      UI.command(command) if print
      result = `#{command}`
      UI.command_output(result) if print
      return result
    end

    # @return true if the currently running program is a unit test
    def self.is_test?
      defined? SpecHelper
    end

    # removes ANSI colors from string
    def self.strip_ansi_colors(str)
      str.gsub(/\e\[([;\d]+)?m/, '')
    end

    # @return [boolean] true if executing with bundler (like 'bundle exec fastlane [action]')
    def self.bundler?
      # Bundler environment variable
      ['BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE'].each do |current|
        return true if ENV.key?(current)
      end
      return false
    end

    # Do we run from a bundled fastlane, which contains Ruby and OpenSSL?
    # Usually this means the fastlane directory is ~/.fastlane/bin/
    # We set this value via the environment variable `FASTLANE_SELF_CONTAINED`
    def self.contained_fastlane?
      ENV["FASTLANE_SELF_CONTAINED"].to_s == "true" && !self.homebrew?
    end

    # returns true if fastlane was installed from the Fabric Mac app
    def self.mac_app?
      ENV["FASTLANE_SELF_CONTAINED"].to_s == "false"
    end

    # returns true if fastlane was installed via Homebrew
    def self.homebrew?
      ENV["FASTLANE_INSTALLED_VIA_HOMEBREW"].to_s == "true"
    end

    # returns true if fastlane was installed via RubyGems
    def self.rubygems?
      !self.bundler? && !self.contained_fastlane? && !self.homebrew? && !self.mac_app?
    end

    # @return [boolean] true if building in a known CI environment
    def self.ci?
      # Check for Jenkins, Travis CI, ... environment variables
      ['JENKINS_HOME', 'JENKINS_URL', 'TRAVIS', 'CIRCLECI', 'CI', 'TEAMCITY_VERSION', 'GO_PIPELINE_NAME', 'bamboo_buildKey', 'GITLAB_CI', 'XCS'].each do |current|
        return true if ENV.key?(current)
      end
      return false
    end

    def self.windows?
      # taken from: http://stackoverflow.com/a/171011/1945875
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def self.linux?
      (/linux/ =~ RUBY_PLATFORM) != nil
    end

    # Is the currently running computer a Mac?
    def self.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    # the valid operating systems
    def self.operating_systems
      [:linux, :mac, :win]
    end

    # the current operating system
    def self.operating_system
      if linux?
        return :linux
      elsif mac?
        return :mac
      elsif windows?
        return :win
      else
        raise 'Could not assume what OS you\'re running, please specify it as much as possible'
      end
    end

    def self.win_64?
      (/x64/ =~ RUBY_PLATFORM) != nil
    end

    def self.win_32?
      (/i386/ =~ RUBY_PLATFORM) != nil
    end

    # Do we want to disable the colored output?
    def self.colors_disabled?
      #ENV["FASTLANE_DISABLE_COLORS"]
    end

    # Does the user use the Mac stock terminal
    def self.mac_stock_terminal?
      !!ENV["TERM_PROGRAM_VERSION"]
    end

    # Does the user use iTerm?
    def self.iterm?
      !!ENV["ITERM_SESSION_ID"]
    end

    # Logs base directory
    #def self.buildlog_path
    #  return ENV["FL_BUILDLOG_PATH"] || "~/Library/Logs"
    #end
  end
  # rubocop:enable Metrics/ModuleLength
end
