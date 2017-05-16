# U3D

U3d is a set of tools to interact with Unity3D from command line. It is available on Linux, Macintosh and Windows.

## What can it do?

U3d provides help for running and installing unity from CLI. Available commands are:

* `u3d available`: List versions available to download

* `u3d download`: Download (and install) Unity

* `u3d installed`: List installed versions

* `u3d local_install`: Install already downloaded packages

* `u3d run`: Run Unity

## Installation

  The gem isn't yet on a public repository, so do
```shell
./local_gem_install.sh
```
## Security

When you install Unity with this tool, you will have to grant it higher privileges so it can perfrom the installation. It means that under MacOS and Linux, you will be asked for your sudo password.

On Windows, you must launch a administrative command interface to be able to run `local_install` and `download` (only if you install for the latter).

## Examples

* List installed versions on your computer:

```shell
u3d installed
```

* List versions you can download and install from Unity, as well as their packages, on Mac:

```shell
u3d available -p -o mac
```

* Download and install version 5.6.0f3 of Unity with its documentation and the WebPlayer package:

```shell
u3d download 5.6.0f3 -p Unity,Documentation,WebPlayer
```
* Run a CLI on the current project given the configured unity version:

```shell
u3d run -- -batchmode -quit -logFile `pwd`/editor.log -executeMethod "WWTK.SimpleBuild.PerformAndroidBuild"
```

You can get further information on how to use U3d by running `u3d --help` (or `u3d -h`).

## SSL Error

If you face an issue similar to this one

    SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed

your ruby setup to work with OpenSSL may want to be fixed.

 * __On MacOS:__

Your version of OpenSSL may be be outdated, make sure you are using the last one.

 * __On Windows:__

A fix to the issue stated above has been found on [StackOverflow](http://stackoverflow.com/questions/5720484/how-to-solve-certificate-verify-failed-on-windows). If you follow the steps described in this topic, you will most likely get rid of this issue.
