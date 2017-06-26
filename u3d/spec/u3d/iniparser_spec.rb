require 'u3d/iniparser'
require 'net/http'

describe U3d do
  describe U3d::INIparser do
    describe '.load_ini' do
      before(:each) do
        @version = 'key'
        @cache = { @version => 'url' }
        name = 'unity-%s-osx.ini' % @version
        @path = File.expand_path(name, "#{ENV['HOME']}/.u3d/ini_files")
      end

      it 'raises an error when trying to load INI files for OS different from Mac or Windows' do
        expect { U3d::INIparser.load_ini('key', @cache, os: 'linux') }.to raise_error
      end
    end
  end
end
