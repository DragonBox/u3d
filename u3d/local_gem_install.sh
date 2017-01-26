rm -f u3d*.gem
# sometimes we need to force bundler...
gem install bundler
#if [[ ! `gem list | grep "^bundler "` ]]; then gem install bundler; fi
bundle install
bundle exec rake install
