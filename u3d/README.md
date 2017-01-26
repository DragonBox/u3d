A set of tools to help run unity on the command line.

# Installation

  The gem isn't yet on a public repo, so do 

    ./local_gem_install.sh

# Examples

* list installed versions

    u3d installed

* run a CLI on the current project given the configured unity version

    u3d run -- -batchmode -quit -logFile `pwd`/editor.log -executeMethod "WWTK.SimpleBuild.PerformAndroidBuild"

* override with a given Unity version and a specific projectpath

    u3d run -u 5.3.6p3 -- -batchmode -quit -logFile `pwd`/editor.log -projectpath `pwd`/treasure -executeMethod "WWTK.SimpleBuild.PerformAndroidBuild"
