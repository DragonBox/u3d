# frozen_string_literal: true

## --- BEGIN LICENSE BLOCK ---
# Original work Copyright (c) 2015-present the fastlane authors
# Modified work Copyright 2019-present WeWantToKnow AS
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

require_relative '../../u3d/utils'

module U3dCore
  class Changelog
    class << self
      def show_changes(gem_name, current_version, update_gem_command: "bundle update")
        did_show_changelog = false

        releases(gem_name).each_with_index do |release, index|
          next unless Gem::Version.new(to_version(release['tag_name'])) > Gem::Version.new(current_version)

          puts("")
          puts(release['name'].green)
          puts(release['body'])
          did_show_changelog = true

          next unless index == 2

          puts("")
          puts("To see all new releases, open https://github.com/DragonBox/#{gem_name}/releases".green)
          break
        end

        puts("")
        puts("Please update using `#{update_gem_command}`".green) if did_show_changelog
      rescue StandardError => e
        # Something went wrong, we don't care so much about this
        UI.error("Unable to show_changes: #{e}")
      end

      def to_version(tag_name)
        tag_name = tag_name[1..-1] if tag_name[0] == 'v'
        tag_name
      end

      def releases(gem_name)
        url = "https://api.github.com/repos/DragonBox/#{gem_name}/releases"
        JSON.parse(U3d::Utils.page_content(url))
      end
    end
  end
end
