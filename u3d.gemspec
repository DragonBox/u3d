# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'u3d/version'

Gem::Specification.new do |spec|
  spec.name        = 'u3d'
  spec.version     = U3d::VERSION
  spec.authors     = ["Jerome Lacoste", "Paul Niezborala"]
  spec.email       = 'jerome@wewanttoknow.com'

  spec.required_ruby_version = '>= 2.6.0'

  spec.summary     = "U3d"
  spec.description = U3d::DESCRIPTION

  spec.homepage    = 'https://github.com/DragonBox/u3d'
  spec.license     = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'colored', '>= 1.2', '< 2.0.0' # terminal
  spec.add_dependency 'commander', '>= 4.4.0', '< 5.0.0' # CLI parser
  spec.add_dependency 'fiddle'
  spec.add_dependency 'filesize', '>= 0.1.1' # File sizes prettifier
  spec.add_dependency 'file-tail', '>= 1.2.0'
  spec.add_dependency 'inifile', '>= 3.0.0', '< 4.0.0' # Parses INI files
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0' # Generate the Xcode config plist file
  spec.add_dependency "rexml" # rexml was unbundled from the stdlib in ruby 3
  spec.add_dependency 'rubyzip', '>= 1.0.0' # Installation of .zip files
  spec.add_dependency 'security', '= 0.1.5' # macOS Keychain manager, a dead project, no updates expected
  # Development only
  spec.add_development_dependency "activesupport", ">= 5.2.4.3" # force secure transitive dep
  spec.add_development_dependency "addressable", ">= 2.8.0" # force secure transitive dep
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "excon", ">= 0.71.0" # force secure transitive dep
  spec.add_development_dependency "github_changelog_generator", ">= 1.16.4"
  spec.add_development_dependency "json", ">= 2.3.0" # force secure transitive dep
  # spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.11.0"
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.5.1'
  spec.add_development_dependency 'rubocop', '~> 1.50' # for ruby 2.6 compatibility
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  # spec.add_development_dependency 'rubocop-rspec', '~> 2.10.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
