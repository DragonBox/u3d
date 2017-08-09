## --- BEGIN LICENSE BLOCK ---
# Copyright (c) 2016-present WeWantToKnow AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
## --- END LICENSE BLOCK ---

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rubocop/rake_task'
# doesn't yet support dot file
# https://github.com/skywinder/github-changelog-generator/issues/473
# require 'github_changelog_generator/task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task :changelog do
  puts "Updating changelog #{ENV['CHANGELOG_GITHUB_TOKEN']}"
  sh "github_changelog_generator" if ENV['CHANGELOG_GITHUB_TOKEN']
end

task :test_all do
  formatter = "--format progress"
  if ENV["CIRCLECI"]
    Dir.mkdir("/tmp/rspec/")
    formatter += " -r rspec_junit_formatter --format RspecJunitFormatter -o /tmp/rspec/rspec.xml"
    TEST_FILES = `(circleci tests glob "spec/**/*_spec.rb" | circleci tests split --split-by=timings)`.tr!("\n", ' ')
    rspec_args = "#{formatter} #{TEST_FILES}"
  else
    formatter += ' --pattern "./spec/**/*_spec.rb"'
    rspec_args = formatter
  end
  sh "rspec #{rspec_args}"
end

task default: %i[rubocop test_all]
