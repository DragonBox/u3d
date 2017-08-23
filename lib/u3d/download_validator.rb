## --- BEGIN LICENSE BLOCK ---
# Copyright (c) 2016-present WeWantToKnow AS
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

module U3d
  class DownloadValidator
    def hash_validation(expected: nil, actual: nil)
      if expected
        if expected != actual
          UI.verbose "Expected hash is #{expected}, file hash is #{actual}"
          UI.important 'File looks corrupted (wrong hash)'
          return false
        end
      else
        UI.verbose 'No hash validation available. File is assumed correct but may not be.'
      end
      true
    end

    def size_validation(expected: nil, actual: nil)
      if expected
        if expected != actual
          UI.verbose "Expected size is #{expected}, file size is #{actual}"
          UI.important 'File looks corrupted (wrong size)'
          return false
        end
      else
        UI.verbose 'No size validation available. File is assumed correct but may not be.'
      end
      true
    end

    def validate(package, file, definition)
      raise NotImplementedError, 'Not implemented yet'
    end
  end

  class LinuxValidator < DownloadValidator
    def validate(package, file, definition)
      return size_validation(expected: definition[package]['size'], actual: File.size(file)) if definition.ini && definition[package]['size']
      UI.important "No file validation available, #{file} is assumed to be correct"
      true
    end
  end

  class MacValidator < DownloadValidator
    def validate(package, file, definition)
      size_validation(expected: definition[package]['size'], actual: File.size(file)) &&
      hash_validation(expected: definition[package]['md5'], actual: Utils.hashfile(file))
    end
  end

  class WindowsValidator < DownloadValidator
    def validate(package, file, definition)
      rounded_size = (File.size(file).to_f / 1024).floor
      size_validation(expected: definition[package]['size'], actual: rounded_size) &&
      hash_validation(expected: definition[package]['md5'], actual: Utils.hashfile(file))
    end
  end
end
