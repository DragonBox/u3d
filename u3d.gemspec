# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'u3d/version'

Gem::Specification.new do |spec|
  spec.name        = 'u3d'
  spec.version     = U3d::VERSION
  spec.authors     = ["Jerome Lacoste", "Paul Niezborala"]
  spec.email       = 'jerome@wewanttoknow.com'

  spec.required_ruby_version = '>= 2.1.0'

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

  spec.add_dependency 'commander', '>= 4.4.0', '< 5.0.0' # CLI parser
  spec.add_dependency 'security', '= 0.1.3' # macOS Keychain manager, a dead project, no updates expected
  spec.add_dependency 'colored', '>= 1.2', '< 2.0.0' # terminal
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0' # Generate the Xcode config plist file
  spec.add_dependency 'inifile', '>= 3.0.0', '< 4.0.0' # Parses INI files
  spec.add_dependency 'filesize', '>= 0.1.1' # File sizes prettifier
  spec.add_dependency 'file-tail', '>= 1.2.0'
  # Development only
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency "pry"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "github_changelog_generator"
  spec.add_development_dependency 'rubocop', '~> 0.49.1'
end
