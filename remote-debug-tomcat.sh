#!/bin/bash

# param1($1) : project's absolute path
# param2($2) : docker instance name

# e.g. ./remote-debug-tomcat.sh $PWD/simple_jsp_proj remote-debug-instance


docker rm -f $2

docker run --name=$2 -d \
-v $1:/usr/local/tomcat/webapps/proj \
-e JPDA_ADDRESS=8000 \
-e JPDA_TRANSPORT=dt_socket \
-e DEBUG_OPTS="-Xdebug -Xrunjdwp:transport:transport=dt_socket,adress=4000,server=y,suspend=n" \
--network host \
tomcat:8 catalina.sh jpda run
