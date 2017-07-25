# U3D

U3d is a set of tools to interact with Unity3D from command line. It is available on Linux, Macintosh and Windows.

## What can it do?

U3d provides help for running and installing unity from CLI. Available commands are:

* `u3d available`: List download-ready versions of Unity3d

![u3d available](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_available.png)

* `u3d install`: Download (and install) Unity3D packages

![u3d install](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_install.png)

* `u3d list`: List installed versions of Unity3d

![u3d list](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_list.png)

* `u3d local_install`: Install downloaded version of Unity3d

* `u3d run`: Run Unity, and parses its output through u3d's log prettifier

![u3d run](https://github.com/DragonBox/u3d/raw/master/docs/assets/u3d_run.png)

The prettifyer is on by default but can be turned off to get Unity3d's raw output.

* `u3d prettify`: Prettify a saved editor logfile

  [Information on how `prettify` works](https://github.com/DragonBox/u3d/blob/master/LOG_RULES.md)

## Installation

```shell
gem install u3d
```

## Security

When you install Unity with this tool, you will have to grant it higher privileges so it can perform the installation. It means that under MacOS and Linux, you will be asked for your `sudo` password.

On Windows, you must launch a administrative command interface to be able to run `local_install` and `install` (only if you install for the latter).

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
* Run a CLI on the current project given the project's configured unity version, displaying prettified logs, while keeping the original logs under `editor.log`:

```shell
u3d run -- -batchmode -quit -logFile `pwd`/editor.log -executeMethod "WWTK.SimpleBuild.PerformAndroidBuild"
```

* Open the proper Unity3d for the current project, displaying the raw editor logs in the command line:

```shell
u3d run -r
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
