= before release
* XXX [PN] core: rename commands (download -> install) (installed -> list)
* [PN] opt-in keychain integration (several commands - same option)
* [PN] message before storing into keychain (inform the user what is going on)
<<<<<<< HEAD
* XXX [PN] add legend (a: alpha, b: beta, f: release candidate/final, p: patch) somewhere in help ?
* u3d install [latest[_stable]|latest_beta|latest_alpha|latest_patch]
* u3d availale [stable|beta|alpha|patch]
* ~~~ [PN] progress speed
=======
* [PN] add legend (a: alpha, b: beta, f: release candidate/final, p: patch) somewhere in help ?
* [PN] progress speed
>>>>>>> 5b7523188815eab28fd5d0633b2eb3c0427d7553
* core: moar tests if needed
* [PN] core: clean up Fastlane related namings (git grep -i fastlane)
* [JL] ensure proper LICENSING
* [PN] core: remove timestamp prefixes for other commands than run
* [JL] prepare documentation / README / site

* XXX [PN] bug: too much output for downloader on console / CI

* bug: password deleted from keychain
WARN [2017-07-02 23:20:34.44]: Root privileges are required
DEBUG [2017-07-02 23:20:34.44]: Fetching password from keychain
DEBUG [2017-07-02 23:20:34.48]: Could not retrieve password
DEBUG [2017-07-02 23:20:34.48]: Attempting to login
DEBUG [2017-07-02 23:20:34.48]: Password does not exist or is empty
DEBUG [2017-07-02 23:20:34.48]: Password missing and context is not interactive. Please make sure it is correct
DEBUG [2017-07-02 23:20:34.48]: Deleting credentials from the keychain
password has been deleted.
keychain: "/Users/Xcloud/Library/Keychains/login.keychain-db"


= post
* core: keep timestamp in run unless surrounding command has it (e.g. fastlane)

* bug: installer shouldn't ask to rename directory of current Unity install if more packageses are coming

* feature to clear credentials

* u3d specific keychain (u3d_credentials_store)

* if failure to downlad a package, diplay available ones
  #No package "Mac" was found for version 5.6.0f3
