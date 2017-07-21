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

require 'u3d/utils'

module U3d
  class UnityVersionNumber
    attr_reader :parts

    def initialize(version)
      parsed = Utils.parse_unity_version(version)
      parsed.each_with_index do |val, index|
        next if val.nil? or index == 3
        parsed[index] = val.to_i
      end
      @parts = parsed
    end

    def to_s
      "#{parts[0]}.#{parts[1]}.#{parts[2]}#{parts[3]}#{parts[4]}"
    end
  end

  class UnityVersionComparator
    include Comparable

    RELEASE_LETTER_STRENGTH = { a: 1, b: 2, f: 3, p: 4 }

    attr :version

    def <=>(anOther)
      comp = @version.parts[0] <=> anOther.version.parts[0]
      return comp if comp != 0
      comp = @version.parts[1] <=> anOther.version.parts[1]
      return comp if comp != 0
      comp = @version.parts[2] <=> anOther.version.parts[2]
      return comp if comp != 0
      comp = RELEASE_LETTER_STRENGTH[@version.parts[3].to_sym] <=> RELEASE_LETTER_STRENGTH[anOther.version.parts[3].to_sym]
      return comp if comp != 0
      return @version.parts[4] <=> anOther.version.parts[4]
    end

    def initialize(version)
      version = UnityVersionNumber.new(version.to_s)
      @version = version
    end
    def inspect
      @version
    end
  end
end
