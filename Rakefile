# frozen_string_literal: true

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
require 'u3d'

UI = U3dCore::UI

# doesn't yet support dot file
# https://github.com/skywinder/github-changelog-generator/issues/473
# require 'github_changelog_generator/task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

class GithubChangelogGenerator
  PATH = '.github_changelog_generator'
  class << self
    def future_release
      s = File.read(PATH)
      s.split("\n").each do |line|
        m = line.match(/future-release=v(.*)/)
        return m[1] if m
      end
      raise "Couldn't find future-release in #{PATH}"
    end

    def future_release=(nextv)
      s = File.read(PATH)
      lines = s.split("\n").map do |line|
        m = line.match(/future-release=v(.*)/)
        if m
          "future-release=v#{nextv}"
        else
          line
        end
      end
      File.write(PATH, "#{lines.join("\n")}\n")
    end
  end
end

class U3dCode
  PATH = 'lib/u3d/version.rb'
  class << self
    def version=(version)
      s = File.read(PATH)
      lines = s.split("\n").map do |line|
        m = line.match(/(.*VERSION = ').*(')/)
        if m
          "#{m[1]}#{version}#{m[2]}"
        else
          line
        end
      end
      File.write(PATH, "#{lines.join("\n")}\n")
    end
  end
end

def run_command(command, error_message = nil)
  output = `#{command}`
  unless $CHILD_STATUS.success?
    error_message = "Failed to run command '#{command}'" if error_message.nil?
    UI.user_error!(error_message)
  end
  output
end

###
### see https://github.com/github/hub/issues/2055
def ensure_hub!
  require 'English'
  `which hub`
  raise "Missing hub command. This script requires the hub command. Get it from https://hub.github.com" unless $CHILD_STATUS.exitstatus.zero?
end

def hub_config
  @hub_config ||=
    begin
      require 'YAML'
      File.open(File.expand_path("~/.config/hub"), 'r:bom|utf-8') { |f| Psych.safe_load(f.read) }
    end
end

def hub_user(server)
  hub_config[server][0]['user']
end

def hub_fork_remote_name
  server = 'github.com'

  user = hub_user(server)

  `git remote -v`.split("\n").map(&:split).select { |a| a[2] == '(push)' && a[1] =~ /#{server}.#{user}/ }.first[0]
end

def github_team
  %w[lacostej niezbop]
end

def github_reviewers
  server = 'github.com'
  github_team - [hub_user(server)]
end
###

desc 'Ensure the git repository is clean. Fails otherwise'
task :ensure_git_clean do
  branch = run_command('git rev-parse --abbrev-ref HEAD', "Couldn't get current git branch").strip
  UI.user_error!("You are not on 'master' but on '#{branch}'") unless branch == "master"
  output = run_command('git status --porcelain', "Couldn't get git status")
  UI.user_error!("git status not clean:\n#{output}") unless output == ""
end

desc 'Ensure we are ready to prepare a PR'
task :prepare_git_pr, [:pr_branch] do |_t, args|
  pr_branch = args['pr_branch']
  raise "Missing pr_branch argument" unless pr_branch

  UI.user_error! "Prepare git PR stopped by user" unless UI.confirm("Creating PR branch #{pr_branch}")
  run_command("git checkout -b #{pr_branch}")
end

desc 'Prepare a release: check repo status, generate changelog, create PR'
task pre_release: 'ensure_git_clean' do
  require 'u3d/version'
  nextversion = U3d::VERSION

  # check not already released
  output = run_command("git tag -l v#{nextversion}").strip
  UI.user_error! "Version '#{nextversion}' already released. Run 'rake bump'" unless output == ''

  gh_future_release = GithubChangelogGenerator.future_release
  UI.user_error! "GithubChangelogGenerator version #{gh_future_release} != #{nextversion}" unless gh_future_release == nextversion

  pr_branch = "release_#{nextversion}"
  Rake::Task["prepare_git_pr"].invoke(pr_branch)

  Rake::Task["changelog"].invoke

  sh('git diff')
  # FIXME: cleanup branch, etc
  UI.user_error! "Pre release stopped by user." unless UI.confirm("CHANGELOG PR for version #{nextversion}. Confirm?")

  msg = "Preparing release for #{nextversion}"
  sh 'git add CHANGELOG.md'
  sh "git commit -m '#{msg}'"

  ensure_hub!
  hub_remote = hub_fork_remote_name
  sh "git push #{hub_remote}"
  sh "hub pull-request -m '#{msg}' -r '#{github_reviewers.join(',')}' -l nochangelog"
  sh 'git checkout master'
  sh "git branch -D #{pr_branch}"
end

desc 'Bump the version number to the version entered interactively; pushes a commit to master'
task bump: 'ensure_git_clean' do
  nextversion = UI.input "Next version will be:"
  UI.user_error! "Bump version stopped by user" unless UI.confirm("Next version will be #{nextversion}. Confirm?")
  U3dCode.version = nextversion
  GithubChangelogGenerator.future_release = nextversion
  sh 'rspec'
  sh 'git add .github_changelog_generator lib/u3d/version.rb Gemfile.lock'
  sh "git commit -m 'Bump version to #{nextversion}'"
  sh 'git push'
end

desc 'Update the changelog, no commit made'
task :changelog do
  UI.user_error!('No CHANGELOG_GITHUB_TOKEN in the environment') unless ENV.key? 'CHANGELOG_GITHUB_TOKEN'
  puts "Updating changelog #{ENV['CHANGELOG_GITHUB_TOKEN']}"
  sh "github_changelog_generator" if ENV['CHANGELOG_GITHUB_TOKEN']
end

desc 'Run all rspec tests'
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

def parse_changelog
  releases = {}
  buffer = nil
  version = nil
  File.readlines("CHANGELOG.md").each do |line|
    if (m = line.match(/^## \[(.*)\]/))
      releases[version] = buffer if buffer
      version = m[1]
      buffer = "#{version}\n\n"
    else
      next unless version # skip first lines

      buffer += line
    end
  end
  releases[version] = buffer
  releases
end

desc 'Create missing Github releases from changelog'
task :create_missing_github_releases, [:force] do |_t, args|
  force = args[:force] || false
  releases = parse_changelog

  known_releases = `hub release`.split("\n")

  releases.keys.reverse.each do |version|
    exist = known_releases.include? version
    if exist && !force
      puts "Skipping existing version #{version}"
      next
    end
    action = exist ? "edit" : "create"
    changelog = releases[version]
    puts "About to #{action} version #{version}"
    require "tempfile"
    Tempfile.create("githubchangelog") do |changelog_file|
      File.write(changelog_file, changelog)
      command = "hub release #{action} #{version} --file #{changelog_file.path}"
      `#{command}`
    end
  end
end

task default: %i[rubocop test_all]
