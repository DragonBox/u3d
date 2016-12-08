require 'u3d/version'

Gem::Specification.new do |s|
  s.name        = 'u3d'
  s.version     = U3d.VERSION
  s.date        = '2016-12-08'
  s.summary     = "U3d"
  s.description = U3d.DESCRIPTION
  s.authors     = ["Jerome Lacoste"]
  s.email       = 'jerome@wewanttoknow.com'
  s.files       = spec.files = Dir["lib/**/*"] + %w(bin/u3d README.md LICENSE)
  s.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
  #s.homepage    = 'http://rubygems.org/gems/u3d'
  s.license     = 'MIT'

  #spec.add_dependency "fastlane_core", ">= 0.59.0", "< 1.0.0" # all shared code and dependencies
  #spec.add_dependency 'terminal-table', '>= 1.4.5', '< 2.0.0' # print out build information
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0' # Generate the Xcode config plist file
  #spec.add_dependency 'rubyzip', '>= 1.1.7' # fix swift/ipa

  # Development only
  spec.add_development_dependency "bundler"
  #spec.add_development_dependency "fastlane", ">= 1.33.0" # yes, we use fastlane for testing
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency "pry"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end