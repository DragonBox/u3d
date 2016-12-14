# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'u3d/version'

Gem::Specification.new do |spec|
  spec.name        = 'u3d'
  spec.version     = U3d::VERSION
  spec.date        = '2016-12-08'
  spec.summary     = "U3d"
  spec.description = U3d::DESCRIPTION
  spec.authors     = ["Jerome Lacoste"]
  spec.email       = 'jerome@wewanttoknow.com'
  spec.files       = spec.files = Dir["lib/**/*"] + %w(bin/u3d README.md LICENSE)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  #s.homepage    = 'http://rubygems.org/gems/u3d'
  spec.license     = 'MIT'

  #spec.add_dependency "fastlane_core", ">= 0.59.0", "< 1.0.0" # all shared code and dependencies
  #spec.add_dependency 'terminal-table', '>= 1.4.5', '< 2.0.0' # print out build information
  spec.add_dependency 'colored', '>= 1.2', '< 2.0.0' # terminal
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