# CI Setup

## Jenkins setup

Example of how to setup Jenkins to install unity automatically on multiple slaves

You might want to do things differently. Here are the decisions we took:

* we install all Unity versions in the same way (i.e. same Unity platform modules for all installs)
* we store the slave root passwords in the Jenkins credentials binding.
* we depend on RVM to be present on the slaves

Prerequisites:
* Install the same version of RVM on all slaves where you will install u3d
* add one root password credential per slave in the jenkins setup. Follow the "U3D_PASSWORD_$SLAVENAME" format 

![jenkins credentials](https://github.com/DragonBox/u3d/raw/master/docs/assets/ci_jenkins_credentials.png)

Required plugins:
* [Credentials Binding Plugin](https://wiki.jenkins.io/display/JENKINS/Credentials+Binding+Plugin)
* [Parametrized Builds](https://wiki.jenkins.io/display/JENKINS/Parameterized+Build)
* [RVM Plugin](https://wiki.jenkins.io/display/JENKINS/RVM+Plugin)
* [ANSI Color plugin](https://wiki.jenkins.io/display/JENKINS/AnsiColor+Plugin)

Set up an install job:

* create a freestyle job

* Add a U3D_VERSION string parameter

![jenkins version parameter](https://github.com/DragonBox/u3d/raw/master/docs/assets/ci_jenkins_version_param.png)

* Configure the nodes you might want to install on as parameters

![node parameter](https://github.com/DragonBox/u3d/raw/master/docs/assets/ci_jenkins_version_node.png)

* Enable console coloring

![console coloring](https://github.com/DragonBox/u3d/raw/master/docs/assets/ci_jenkins_ansi.png)

* Enable RVM

![console coloring](https://github.com/DragonBox/u3d/raw/master/docs/assets/ci_jenkins_rvm.png)

* Configure the slave passwords

![configure the slave passwords](https://github.com/DragonBox/u3d/raw/master/docs/assets/ci_jenkins_secret_passwords.png)


* add an "execute Shell" step
```bash
# config. We could make this an option to the job. Or be project specific.
U3D_INSTALL_ARGS=-p Unity,Android,iOS,Linux,Windows,WebGL

# install or update u3d if it isn't already present
if [[ ! `which u3d` ]]; then 
  gem install u3d
else
  gem update u3d
fi

echo "${U3D_INSTALL_ARGS}"

# display whether or not the slave has credentials stored
u3d credentials check

# fetch the password for the slave from the credentials
PASS_KEY=U3D_PASSWORD_${NODE_NAME}
echo "PASS KEY: ${PASS_KEY}"
export U3D_PASSWORD=${!PASS_KEY}

# install the specified version with the specified arguments
u3d install --trace --verbose $U3D_VERSION $U3D_INSTALL_ARGS 
u3d list
````
