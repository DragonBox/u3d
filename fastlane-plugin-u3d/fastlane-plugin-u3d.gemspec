# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/u3d/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-u3d'
  spec.version       = Fastlane::U3d::VERSION
  spec.author        = %q{Jerome Lacoste}
  spec.email         = %q{jerome.lacoste@gmail.com}

  spec.summary       = %q{Fastgame's u3d (a Unity3d CLI) integration}
  spec.homepage      = "https://github.com/DragonBox/u3d/tree/master/fastlane-plugin-u3d"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'u3d', '>= 0.9', "<2.0"

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.35.0'
end
