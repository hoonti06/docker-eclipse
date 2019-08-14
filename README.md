# NOTE1 : Forked from https://github.com/DrSnowbird/jdk-mvn-py3 and Customized
 
# OpenJDK Java 8 (1.8.0_222) JDK + Maven 3.6 + node 11 + npm 6 + Gradle 5.5

# NOTICE: ''Change to use Non-Root implementation''
This new release is designed to support the deployment for Non-Root child images implementations and deployments to platform such as OpenShift or RedHat host operating system which requiring special policy to deploy. And, for better security practice, we decided to migrate (eventaully) our Docker containers to use Non-Root implementation. 
Here are some of the things you can do if your images requiring "Root" acccess - you `really` want to do it:
1. For Docker build: Use "sudo" or "sudo -H" prefix to your Dockerfile's command which requiring "sudo" access to install packages.
2. For Docker container (access via shell): Use "sudo" command when you need to access root privilges to install packages or change configurations.
3. Or, you can use older version of this kind of base images which use "root" in Dockerfile.
4. Yet, you can also modify the Dockerfile at the very bottom to remove/comment out the "USER ${USER}" line so that your child images can have root as USER.
5. Finally, you can also, add a new line at the very top of your child Docker image's Dockerfile to include "USER root" so that your Docker images built will be using "root".

We like to promote the use of "Non-Root" images as better Docker security practice. And, whenever possible, you also want to further confine the use of "root" privilges in your Docker implementation so that it can prevent the "rooting hacking into your Host system". To lock down your docker images and/or this base image, you will add the following line at the very end to remove sudo: `(Notice that this might break some of your run-time code if you use sudo during run-time)`
```
sudo agt-get remove -y sudo
```
After that, combining with other Docker security practice (see below references), you just re-build your local images and re-deploy it as non-development quality of docker container. However, there are many other practices to secure your Docker containes. See below:

* [Docker security | Docker Documentation](https://docs.docker.com/engine/security/security/)
* [5 tips for securing your Docker containers - TechRepublic](https://www.techrepublic.com/article/5-tips-for-securing-your-docker-containers/)
* [Docker Security - 6 Ways to Secure Your Docker Containers](https://www.sumologic.com/blog/security/securing-docker-containers/)
* [Five Docker Security Best Practices - The New Stack](https://thenewstack.io/5-docker-security-best-practices/)

# Components:
* Eclipse `2019-06` JEE version (you can change in Dockerfile)
* openjdk version `1.8.0_222``
  OpenJDK Runtime Environment (build 1.8.0_222-8u222-b10-1ubuntu1~18.04.1-b10)
  OpenJDK 64-Bit Server VM (build 25.222-b10, mixed mode)
* Apache Maven `3.6`
* Node `v11.15.0` + npm `6.7.0` (from NodeSource official Node Distribution)
* Gradle `5.5`
* X11 display desktop
* Other tools: git wget unzip, ..., etc.

# Quick commands
* build.sh - build local image
* logs.sh - see logs of container
* run.sh - run the container
* shell.sh - shell into the container
* stop.sh - stop the container
* test/tryJava.sh : test Java
* test/tryNodeJS.sh : test NodeJS
* test/tryWebSocketServer.sh : test WebSockert NodeJS Server

# How to use and quick start running?
1. $ docker pull hoonti06/docker-eclipse-min
2. $ git clone https://github.com/hoonti06/docker-eclipse-min
3. $ cd docker-eclipse-min
4. $ ./run.sh

# Default Run (test) - Just entering Container
```
./run.sh
```

# Test Run Java and NodeJS 
```
./tryJava.sh
./tryNodeJS.sh
./tryPython.sh
./tryWebSockerServer.sh
```
# Default Build (locally)
You can build your own image locally.
Note that the default build docker is "2019-06" version. 
If you want to build older Eclipse like "photon", you can following instruction in next section
```
./build.sh
```

# Build (Older Eclipse version, e.g. Photon)
Two ways (at least) to build:
### Way-1 (**Recommended**):
If you use command line "'**./build.sh**'", you can modify "'**./.env**' (old filename ./docker.env)" file and then, run "./build.sh" to build image
```
## -- Eclipse versions: 2019-06, photon, oxygen, etc.: -- ##
ECLIPSE_VERSION=2019-06
or
ECLIPSE_VERSION=photon
```
Then, 
```
./build.sh
```
### Way-2: 
Modify the line in '**./Dockefile**' as below if you use '**docker-compose**' or Openshift CI/CD. That is, you are not using command line '**./build.sh**' to build container image.
```
## -- Eclipse versions: 2019-06, photon, oxygen, etc.: -- ##
ENV ECLIPSE_VERSION=${ECLIPSE_VERSION:-2019-06}
or
ENV ECLIPSE_VERSION=${ECLIPSE_VERSION:-photon}
```
Then, 
```
docker-compose up -d 
```
# Configurations (Optional)
If you run "./run.sh" instead of "docker-compose up", you don't have to do anything as below.

* In `run.sh`  
	* `BASE_DATA_DIR` : `$HOME/data-docker`  
	* `PACKAGE` : `${imageTag##*/}` (docker-eclipse)  
	* `LOCAL_VOLUME_DIR` : `${BASE_DATA_DIR}`/`${PACKAGE}` ($HOME/data-docker/docker-eclipse)  

	You can put your 'java projects' in `LOCAL_VOLUME_DIR`. Of course, you can change `LOCAL_VOLUME_DIR`  
* The script "./run.sh" will re-use or create the local directory in your $HOME directory with the path below to map into the docker's internal `/eclipse-workspace`(default) and `/.eclipse` directory.  

	* The below configurations will ensure all `your projects` created in the container's `/eclipse-workspace` being "persistent" in your local directory, "$HOME/data-docker/eclipse-docker/eclipse-workspace", for your repetitive restart docker container.  
      ```
      $HOME/data-docker/eclipse-docker/eclipse-workspace
      ```

	* The below configuration will ensure all `your eclipse configuration(theme, plugin, etc)` created in the container's `/.eclipse` being "persistent" in your local directory, "$HOME/data-docker/eclipse-docker/.eclipse", for your repetitive restart docker container.
      ```
      $HOME/data-docker/eclipse-docker/.eclipse
      ```


### Create Customized Volume Mapping for "docker-compose"
You can create your own customzied host file mapping, e.g.
```
mkdir -p <my_host_directory>/eclipse-workspace
mkdir -p <my_host_directory>/.eclipse 
```
Then, run docker-comp
```
docker-compose up -d
```
# Distributed Storage
This project provides simple host volumes. For using more advanced storage solutions, there are a few distributed cluster storage options available, e.g., Lustre (popular in HPC), GlusterFS, Ceph, etc.

# Base the image to build add-on components

```Dockerfile
FROM hoonti06/docker-eclipse-min
... (then your customization Dockerfile code here)
```

# Manually setup to Run the image

Then, you're ready to run:
- make sure you create your work directory, e.g., ./data

```bash
mkdir ./data
docker run -d --name my-docker-eclipse-min -v $PWD/data:/data -i -t hoonti06/docker-eclipse-min
```

# Build and Run your own image
Say, you will build the image "my/docker-elcipse-min".
#
```bash
docker build -t my/docker-eclipse-min .
```

To run your own image, say, with dockerEclipseMin

```bash
mkdir ./data
docker run -d --name dockerEclipseMin -v $PWD/data:/data -i -t my/docker-eclipse-min
```

# Shell into the Docker instance

```bash
docker exec -it dockerEclipseMin /bin/bash
```

# Compile or Run java -- while no local installation needed
Remember, the default working directory, /data, inside the docker container -- treat is as "/".
So, if you create subdirectory, "./data/workspace", in the host machine and 
the docker container will have it as "/data/workspace".

```java
#!/bin/bash -x
mkdir ./data
cat >./data/HelloWorld.java <<-EOF
public class HelloWorld {
   public static void main(String[] args) {
      System.out.println("Hello, World");
   }
}
EOF
cat ./data/HelloWorld.java
alias djavac='docker run -it --rm --name dockerEclipseMin -v '$PWD'/data:/data hoonti06/docker-eclipse-min javac'
alias djava='docker run -it --rm --name dockerEclipseMin -v '$PWD'/data:/data hoonti06/docker-eclipse-min java'
djavac HelloWorld.java
djava HelloWorld
```
And, the output:
```
Hello, World
```
Hence, the alias above, "djavac" and "djava" is your docker-based "javac" and "java" commands and 
it will work the same way as your local installed Java's "javac" and "java" commands. 

# Run JavaScript -- while no local installation needed
Run the NodeJS mini-server script:
```
./tryNodeJS.sh
```
Then, open web browser to go to http://0.0.0.0:3000/ to NodeJS mini-web server test.

#

# To run specialty Java/Scala IDE alternatives
However, for larger complex projects, you might want to consider to use Docker-based IDE. 
For example, try the following Docker-based IDEs:
* [hoonti06/docker-eclipse](https://hub.docker.com/r/hoonti06/docker-eclipse)
* [openkbs/docker-atom-editor](https://hub.docker.com/r/openkbs/docker-atom-editor/)
* [openkbs/eclipse-photon-docker](https://hub.docker.com/r/openkbs/eclipse-photon-docker/)
* [openkbs/eclipse-photon-vnc-docker](https://hub.docker.com/r/openkbs/eclipse-photon-vnc-docker/)
* [openkbs/eclipse-oxygen-docker](https://hub.docker.com/r/openkbs/eclipse-oxygen-docker/)
* [openkbs/intellj-docker](https://hub.docker.com/r/openkbs/intellij-docker/)
* [openkbs/intellj-vnc-docker](https://hub.docker.com/r/openkbs/intellij-vnc-docker/)
* [openkbs/knime-vnc-docker](https://hub.docker.com/r/openkbs/knime-vnc-docker/)
* [openkbs/netbeans9-docker](https://hub.docker.com/r/openkbs/netbeans9-docker/)
* [openkbs/netbeans](https://hub.docker.com/r/openkbs/netbeans/)
* [openkbs/papyrus-sysml-docker](https://hub.docker.com/r/openkbs/papyrus-sysml-docker/)
* [openkbs/pycharm-docker](https://hub.docker.com/r/openkbs/pycharm-docker/)
* [openkbs/scala-ide-docker](https://hub.docker.com/r/openkbs/scala-ide-docker/)
* [openkbs/sublime-docker](https://hub.docker.com/r/openkbs/sublime-docker/)
* [openkbs/webstorm-docker](https://hub.docker.com/r/openkbs/webstorm-docker/)
* [openkbs/webstorm-vnc-docker](https://hub.docker.com/r/openkbs/webstorm-vnc-docker/)

# See also
* [Java Development in Docker](https://blog.giantswarm.io/getting-started-with-java-development-on-docker/)
* [Alpine small image JDKs](https://github.com/frol/docker-alpine-oraclejdk8)
* [NPM Prefix for not using SUDO NPM](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally)

# Proxy & Certificate Setup
* [Setup System and Browsers Root Certificate](https://thomas-leister.de/en/how-to-import-ca-root-certificate/)

# Corporate Proxy Root and Intemediate Certificates setup for System and Web Browsers (FireFox, Chrome, etc)
1. Save your corporate's Certificates in the currnet GIT directory, `./certificates`
2. During Docker run command, 
```
   -v `pwd`/certificates:/certificates ... (the rest parameters)
```
If you want to map to different directory for certificates, e.g., /home/developer/certificates, then
```
   -v `pwd`/certificates:/home/developer/certificates -e SOURCE_CERTIFICATES_DIR=/home/developer/certificates ... (the rest parameters)
```
3. And, inside the Docker startup script to invoke the `~/scripts/setup_system_certificates.sh`. Note that the script assumes the certficates are in `/certificates` directory.
4. The script `~/scripts/setup_system_certificates.sh` will automatic copy to target directory and setup certificates for both System commands (wget, curl, etc) to use and Web Browsers'.

# [Releases information](https://github.com/hoonti06/docker-eclipse-min/release-info.md)

