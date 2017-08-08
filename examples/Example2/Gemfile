source 'https://rubygems.org'

gem 'fastlane'
REPO_ROOT = File.expand_path(File.join('..', '..'))
gem 'u3d', path: REPO_ROOT

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
# rubocop:disable Eval
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
# rubocop:enable Eval
