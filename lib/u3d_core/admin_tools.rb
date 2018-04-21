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
module U3dCore
  class AdminTools
    # move one path to a new path
    def self.move_file(source_path, new_path, command, dry_run: false)
      if source_path == new_path
        UI.important "move_file does nothing if the path won't change (#{source_path})"
        return false
      end

      if dry_run
        UI.message "'#{source_path}' would move to '#{new_path}'"
      else
        UI.important "Moving '#{source_path}' to '#{new_path}'..."
        U3dCore::CommandExecutor.execute(command: command, admin: true)
        UI.success "Successfully moved '#{source_path}' to '#{new_path}'"
      end
      true
    rescue StandardError => e
      UI.error "Unable to move '#{source_path}' to '#{new_path}': #{e}"
      false
    end
  end
end