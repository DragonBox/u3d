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

    RELEASE_LETTER_STRENGTH = { "a": 1, "b": 2, "f": 3, "p": 4 }

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

