# U3D

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/DragonBox/u3d/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/u3d.svg?style=flat)](https://rubygems.org/gems/u3d)
[![Build Status](https://img.shields.io/circleci/project/DragonBox/u3d/master.svg?style=flat)](https://circleci.com/gh/DragonBox/u3d)
[![Coverage Status](https://coveralls.io/repos/github/DragonBox/u3d/badge.svg?branch=master)](https://coveralls.io/github/DragonBox/u3d?branch=master)

U3d is a set of tools to interact with Unity3D from command line. It is available on Linux, Macintosh and Windows.

---

## What can it do?

U3d provides help for running and installing unity from CLI.

U3d knows about your Unity project and behaves differently if invoked from within a Unity project directory. For example, it can run or download the version required by your project without you having to specify it.

Available commands are:

* `u3d available`: List download-ready versions of Unity3d

![u3d available](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_available.png)

* `u3d install`: Download and/or install Unity3D packages

![u3d install](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_install.png)

* `u3d list`: List installed versions of Unity3d

![u3d list](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_list.png)

* `u3d run`: Run Unity, and parses its output through u3d's log prettifier.

Here we start with the proper version of Unity:

![u3d run without arguments](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_run_current.png)

Here we pass some arguments:
![u3d run with arguments](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_run.png)

The prettifyer is on by default but can be turned off to get Unity3d's raw output.

* `u3d prettify`: Prettify a saved editor logfile

  [Information on how `prettify` works](https://github.com/DragonBox/u3d/blob/master/LOG_RULES.md)

* `u3d dependencies`: [Linux] Install dependencies that Unity don't install by default on Linux.

## Installation

```shell
gem install u3d
```

## Unity versions numbering

Unity3d uses the following version formatting: 0.0.0x0. The \'x\' can takes different values:
  * 'f' are the main release candidates for Unity3d
  * 'p' are patches fixing those releases
  * 'b' are the beta releases
  * 'a' are the alpha releases (not currently discovered online)

Some versions are known to have a different numbering, e.g. Linux 2017.1.0f3 is named 2017.1.0xf3Linux. Its `ProjectSettings/ProjectVersion.txt` will contain the Linux specific version.

When referencing to a version on the CLI, u3d sanitizes these weird versions. For example, if you ask u3d to launch unity 2017.1.0f3 on Linux, you can use `u3d -u 2017.1.0f3` and it will find "2017.1.0xf3Linux".

## Default Installation paths

  The standard Unity installer has some quirks:

  * on Mac, it always installs Unity on `/Applications/Unity`. If you want to add a module to a particular version, you will have to move the unity you are trying to extend to that particular location

  * on Linux, most versions are installed as `unity-editor-$version` with `version` following the 'standard' numbering (except for some weird versions, see above). Unity lets you install the program in the directory of your choice

  Also for easing discoverability, it is recommended that you install your Unity versions in a similar area.

  For these reasons, u3d has standardized the installation paths of the Unity version it installs.

  * on Mac, versions are installed under `/Applications/Unity_$version`
  * on Linux, versions are installed under `/opt/unity-editor-$version`
  * on Windows, versions are installed under `C:/Program Files/Unity_$version`

  u3d should be able to find the different unity installed under those locations. If the Unity installations are not in those locations, u3d might not find them automatically.

## Sanitize / standardize Unity3d installation paths

  If you have installed Unity in different locations, u3d might discover them and propose you to move them to its standard location. The procedure should be self described and easily revertible (manually). This sanitization operation is only proposed in interactive mode (i.e. if you are not using u3d unattended, e.g. in a build script on a CI server).

![u3d sanitize](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_sanitize.png)

## Security

When you install Unity with this tool, you will have to grant it higher privileges so it can perform the installation. It means that under MacOS and Linux, you will be asked for your `sudo` password.

On Windows, you must launch an administrative command interface to be able to run `install` without the `--no-install` option. Same goes for any kind of sanitization where u3d would move files around.

## Examples

* List installed versions on your computer:

```shell
u3d list
```

* List versions you can download and install from Unity, as well as their packages, on Mac:

```shell
u3d available -p -o mac
```

* Download and install version 5.6.0f3 of Unity with its documentation and the WebPlayer package:

```shell
u3d install 5.6.0f3 -p Unity,Documentation,WebPlayer
```

* Download version 5.6.0f3 of Unity without installing it:

```shell
u3d install 5.6.0f3 --no-install
```

* Install previously downloaded version 5.6.0f3:

```shell
u3d install 5.6.0f3 --no-download
```

* Run a CLI on the current project given the project's configured unity version, displaying prettified logs, while keeping the original logs under `editor.log`:

```shell
u3d run -- -batchmode -quit -logFile `pwd`/editor.log -executeMethod "WWTK.SimpleBuild.PerformAndroidBuild"
```

* Open the proper Unity3d for the current project, displaying the raw editor logs in the command line:

```shell
u3d run -r
```

You can get further information on how to use U3d by running `u3d --help` (or `u3d -h`).

## How-tos

### Reuse u3d install on a CI environment

Here you have multiple options

* pass the password using `U3D_PASSWORD` environment variable

* if on Mac, use the keychain option (you set it before hand on the machine, e.g. from the command line using `u3d credentials` add (use `u3d credentials check` to verify) and then use `u3d install -k` to activate the keychain while installing.

### Troubleshoot

Use the global `--verbose` argument to enable debug logs.

Use the global `-t` argument to display stack traces if a crash occurs.

### Solve SSL Errors

If you face an issue similar to this one

```shell
SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed
```
your ruby setup to work with OpenSSL probably needs to be fixed.

 * __On MacOS:__

Your version of OpenSSL may be be outdated, make sure you are using the last one.

 * __On Windows:__

A fix to the issue stated above has been found on [StackOverflow](http://stackoverflow.com/questions/5720484/how-to-solve-certificate-verify-failed-on-windows). If you follow the steps described in this topic, you will most likely get rid of this issue.
