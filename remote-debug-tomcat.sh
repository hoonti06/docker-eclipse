#!/bin/bash

# project's absolute path
PROJECT_PATH=~/data-docker/docker-eclipse/eclipse-workspace/simple_jsp 

# docker instance name
INSTANCE_NAME=remote-debug-tomcat 

PORT=8000
TOMCAT_VERSION=8

docker rm -f ${INSTANCE_NAME}

docker run --name=${INSTANCE_NAME} -d \
-v ${PROJECT_PATH}:/usr/local/tomcat/webapps/proj \
-e JPDA_ADDRESS=${PORT} \
-e JPDA_TRANSPORT=dt_socket \
-e DEBUG_OPTS="-Xdebug -Xrunjdwp:transport:transport=dt_socket,address=${PORT},server=y,suspend=n" \
--network host \
tomcat:${TOMCAT_VERSION} catalina.sh jpda run
