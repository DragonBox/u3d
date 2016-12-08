require 'plist'

# Mac specific only right now
module U3d
  class Installation
    attr_reader :path, :version

    def initialize(path: nil)
      @path=path
    end

    def version
      plist['CFBundleVersion']
    end

    def plist
      @plist ||= Plist::parse_xml("#{@path}/Contents/Info.plist")
    end
  end

  class Installer
    def installed
      unless (`mdutil -s /` =~ /disabled/).nil?
        $stderr.puts 'Please enable Spotlight indexing for /Applications.'
        exit(1)
      end

      bundle_identifiers=['com.unity3d.UnityEditor4.x', 'com.unity3d.UnityEditor5.x']

      mdfind_args = bundle_identifiers.map{|bi| "kMDItemCFBundleIdentifier == '#{bi}'"}.join(" || ")

      command="mdfind \"#{mdfind_args}\" 2>/dev/null" 
      versions=`#{command}`.split("\n").map {|path| Installation.new(path: path) }

      versions.sort!{ |x,y| x.version <=> y.version }
    end
  end

  class Commands
    class << self
      def list_installed
        puts Installer.new.installed.map {|v| "#{v.version}\t(#{v.path})" }.join("\n")
      end
    end
  end
end