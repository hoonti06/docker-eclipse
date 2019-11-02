# Forked from [DrSnowbird/eclipse-photon-docker](https://github.com/DrSnowbird/eclipse-photon-docker) and then, customized

# [hoonti06/docker-jdk-x11](https://github.com/hoonti06/docker-jdk-x11) + eclipse (2019-06)

# Components:
* [hoonti06/docker-jdk-x11](https://hub.docker.com/r/hoonti06/docker-jdk-x11) (base image)
* Eclipse `2019-06` JEE version (you can change in Dockerfile)
 
# Quick commands
* run.sh - run the container
* stop.sh - stop the container
* build.sh - build local image
* shell.sh - shell into the container
* logs.sh - see logs of container

 
# Pull the image from Docker Repository
```
$ docker pull hoonti06/docker-eclipse
```

# Run (recommended for easy-run eclipse)
```
$ ./run.sh
```

# Build
You can build your own image locally.
Note that the default build docker is "2019-06" version. 
If you want to build older Eclipse like "photon", you can following instruction in next section
```
$ ./build.sh
```

# Customizing Build (Older Eclipse version, e.g. Photon)
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
$ ./build.sh
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
$ docker-compose up -d 
```

# Default volume mapping table
|                    Host                    |           Guest(Container)          |        remarks       |
|:------------------------------------------:|:-----------------------------------:|:--------------------:|
| $HOME/data-docker/.m2                      | /home/developer/.m2                 |                      |
| $HOME/data-docker/.gradle                  | /home/developer/.gradle             |                      |
| $HOME/data-docker/workspace                | /home/developer/workspace           |                      |
| $HOME/data-docker/docker-eclipse/.eclipse  | /home/developer/.eclipse            | VOLUMES_LIST in .env |
| $HOME/data-docker/docker-eclipse/.metadata | /home/developer/workspace/.metadata |                      |

# Configurations (Optional)
if you run "docker-compose up" or customize your project (not just run "./run.sh"), you have to know the content as below.

* In **run.sh**  
	* `BASE_DATA_DIR` : `$HOME/data-docker`  
	* `PACKAGE` : `${imageTag##*/}` (docker-eclipse)  
	* `LOCAL_VOLUME_DIR` : `${BASE_DATA_DIR}`/`${PACKAGE}` ($HOME/data-docker/docker-eclipse)  

	You can put your **java projects** in `LOCAL_VOLUME_DIR`. Of course, you can change `LOCAL_VOLUME_DIR`  
* The script "./run.sh" will re-use or create the local directory in your $HOME directory with the path below to map into the docker's internal `/eclipse-workspace`(default) and `/.eclipse` directory.  

	* The below configurations will ensure **all your projects** created in the container's **/workspace** being "persistent" in your local directory, "$HOME/data-docker/workspace", for your repetitive restart docker container.  
      ```
      $HOME/data-docker/workspace
      ```

	* The below configuration will ensure **all your eclipse configuration(theme, plugin, etc)** created in the container's **/.eclipse** being "persistent" in your local directory, "$HOME/data-docker/docker-eclipse/.eclipse", for your repetitive restart docker container.
      ```
      $HOME/data-docker/docker-eclipse/.eclipse
      ```
	* `#VOLUMES_LIST` in **.env** is used to make var `VOLUME_MAP` in **run.sh** **_(NOT to be used in 'build.sh', put '#' before 'VOLUMES_LIST')_**


### Create Customized Volume Mapping for "docker-compose"
You can create your own customzied host file mapping, e.g.
```
$ mkdir -p <my_host_directory>/eclipse-workspace
$ mkdir -p <my_host_directory>/.eclipse 
```

Then, run docker-comp
```
docker-compose up -d
```

# Distributed Storage
This project provides simple host volumes. For using more advanced storage solutions, there are a few distributed cluster storage options available, e.g., Lustre (popular in HPC), GlusterFS, Ceph, etc.

 
# To run specialty Java/Scala IDE alternatives
However, for larger complex projects, you might want to consider to use Docker-based IDE. 
For example, try the following Docker-based IDEs:
* [hoonti06/docker-intellij](https://hub.docker.com/r/hoonti06/docker-intellij)
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

# Display X11 Issue
More resource in X11 display of Eclipse on your host machine's OS, please see
* [X11 Display problem](https://askubuntu.com/questions/871092/failed-to-connect-to-mir-failed-to-connect-to-server-socket-no-such-file-or-di)
* [X11 Display with Xhost](http://www.ethicalhackx.com/fix-gtk-warning-cannot-open-display/)
 
# Other possible Issues
You might see the warning message in the launching xterm console like below, you can just ignore it. I googles around and some blogs just suggested to ignore since the IDE still functional ok.
```
** (eclipse:1): WARNING **: Couldn't connect to accessibility bus: Failed to connect to socket /tmp/dbus-wrKH8o5rny: Connection refused
** (java:7): WARNING **: Couldn't connect to accessibility bus: Failed to connect to socket /tmp/dbus-wrKH8o5rny: Connection refused
