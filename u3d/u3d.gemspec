# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'u3d/version'

Gem::Specification.new do |spec|
  spec.name        = 'u3d'
  spec.version     = U3d::VERSION
  spec.date        = '2016-12-08'
  spec.authors     = ["Jerome Lacoste"]
  spec.email       = 'jerome@wewanttoknow.com'

  spec.summary     = "U3d"
  spec.description = U3d::DESCRIPTION

  #spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'colored', '>= 1.2', '< 2.0.0' # terminal
  spec.add_dependency 'plist', '>= 3.1.0', '< 4.0.0' # Generate the Xcode config plist file

  # Development only
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency "pry"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end