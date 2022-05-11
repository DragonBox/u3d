# frozen_string_literal: true

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
module U3dCore
  class Version
    include Comparable
    attr_reader :major, :minor, :patch

    def initialize(version)
      @major, @minor, @patch = version.split('.').map(&:to_i)
    end

    def to_a
      [major, minor, patch].compact
    end

    def to_s
      to_a.join('.')
    end

    def <=>(other)
      (major <=> other.major).nonzero? ||
        (minor <=> other.minor).nonzero? ||
        patch <=> other.patch
    end
  end
end
