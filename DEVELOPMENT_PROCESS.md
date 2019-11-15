= Notes for dev team

* prepare a version

`rake bump`

`rake pre_release`

* make a release

`rake release`

= release of the fastlane plugin

`cd fastlane-plugin-u3d`

bump the version in `lib/fastlane/plugin/u3d/version.rb`

`bundle exec rake release`

see https://docs.fastlane.tools/plugins/create-plugin/#rubygems