rm -f u3d*.gem
if [[ ! `gem list | grep "^bundler "` ]]; then gem install bundler; fi
bundle install
gem build u3d.gemspec
gem install *.gem
