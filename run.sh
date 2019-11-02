#!/bin/bash

MY_DIR=$(dirname "$(readlink -f "$0")")

if [ $# -lt 1 ]; then
    echo "Usage: "
    echo "  ${0} <container_shell_command>"
    echo "e.g.: "
    echo "  ${0} ls -al "
fi

###################################################
#### ---- Change this only to use your own ----
###################################################
ORGANIZATION=hoonti06
BASE_DATA_DIR="$HOME/data-docker"

###################################################
#### **** Container package information ****
###################################################
MY_IP=`ip route get 1|awk '{print$NF;exit;}'`
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag="${ORGANIZATION}/${DOCKER_IMAGE_REPO}"
PACKAGE="${imageTag##*/}"

#########################################################################################################
######################## DON'T CHANGE LINES STARTING BELOW (unless you need to) #########################
#########################################################################################################
LOCAL_VOLUME_DIR="${BASE_DATA_DIR}/${PACKAGE}"
## -- Container's internal Volume base DIR
DOCKER_VOLUME_DIR="/home/developer"


###################################################
#### ---- Detect docker ----
###################################################
DOCKER_ENV_FILE="./.env"
function detectDockerEnvFile() {
    curr_dir=`pwd`
    if [ -s "./.env" ]; then
        echo "--- INFO: ./.env Docker Environment file (.env) FOUND!"
        DOCKER_ENV_FILE="./.env"
    else
        echo "--- INFO: ./.env Docker Environment file (.env) NOT found!"
        if [ -s "./docker.env" ]; then
            DOCKER_ENV_FILE="./docker.env"
        else
            echo "*** WARNING: Docker Environment file (.env) or (docker.env) NOT found!"
        fi
    fi
}
detectDockerEnvFile

###################################################
#### ---- Function: Generate volume mappings  ----
####      (Don't change!)
###################################################
VOLUME_MAP=""
#### Input: VOLUMES - list of volumes to be mapped
hasPattern=0
function hasPattern() {
    detect=`echo $1|grep "$2"`
    if [ "${detect}" != "" ]; then
        hasPattern=1
    else
        hasPattern=0
    fi
}

function generateVolumeMapping() {
    if [ "$VOLUMES_LIST" == "" ]; then
        ## -- If locally defined in this file, then respect that first.
        ## -- Otherwise, go lookup the docker.env as ride-along source for volume definitions
        VOLUMES_LIST=`cat ${DOCKER_ENV_FILE}|grep "^#VOLUMES_LIST= *"|sed "s/[#\"]//g"|cut -d'=' -f2-`
    fi
    for vol in $VOLUMES_LIST; do
        echo "$vol"
        hasColon=`echo $vol|grep ":"`
        ## -- allowing change local volume directories --
        if [ "$hasColon" != "" ]; then
            left=`echo $vol|cut -d':' -f1`
            right=`echo $vol|cut -d':' -f2`
            leftHasDot=`echo $left|grep "\./"`
            if [ "$leftHasDot" != "" ]; then
                ## has "./data" on the left
                if [[ ${right} == "/"* ]]; then
                    ## -- pattern like: "./data:/containerPath/data"
                    echo "-- pattern like ./data:/data --"
                    VOLUME_MAP="${VOLUME_MAP} -v `pwd`/${left}:${right}"
                else
                    ## -- pattern like: "./data:data"
                    echo "-- pattern like ./data:data --"
                    VOLUME_MAP="${VOLUME_MAP} -v `pwd`/${left}:${DOCKER_VOLUME_DIR}/${right}"
                fi
                mkdir -p `pwd`/${left}
                ls -al `pwd`/${left}
            else
                ## No "./data" on the left
                if [[ ${right} == "/"* ]]; then
                    ## -- pattern like: "data:/containerPath/data"
                    echo "-- pattern like ./data:/data --"
                    VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/${left}:${right}"
                else
                    ## -- pattern like: "data:data"
                    echo "-- pattern like data:data --"
                    VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/${left}:${DOCKER_VOLUME_DIR}/${right}"
                fi
                mkdir -p ${LOCAL_VOLUME_DIR}/${left}
                ls -al ${LOCAL_VOLUME_DIR}/${left}
            fi
        else
            ## -- pattern like: "data"
            echo "-- default sub-directory (without prefix absolute path) --"
            VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/$vol:${DOCKER_VOLUME_DIR}/$vol"
            mkdir -p ${LOCAL_VOLUME_DIR}/$vol
            ls -al ${LOCAL_VOLUME_DIR}/$vol
        fi
    done
	VOLUME_MAP="${VOLUME_MAP} -v ${BASE_DATA_DIR}/workspace:${DOCKER_VOLUME_DIR}/workspace"
	VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/.metadata:${DOCKER_VOLUME_DIR}/workspace/.metadata"
	VOLUME_MAP="${VOLUME_MAP} -v ${BASE_DATA_DIR}/.m2:${DOCKER_VOLUME_DIR}/.m2"
	VOLUME_MAP="${VOLUME_MAP} -v ${BASE_DATA_DIR}/.gradle:${DOCKER_VOLUME_DIR}/.gradle"
}
#### ---- Generate Volumes Mapping ----
generateVolumeMapping
echo ${VOLUME_MAP}

###################################################
#### ---- Function: Generate port mappings  ----
####      (Don't change!)
###################################################
PORT_MAP=""
function generatePortMapping() {
    if [ "$PORTS" == "" ]; then
        ## -- If locally defined in this file, then respect that first.
        ## -- Otherwise, go lookup the ${DOCKER_ENV_FILE} as ride-along source for volume definitions
        PORTS_LIST=`cat ${DOCKER_ENV_FILE}|grep "^#PORTS_LIST= *"|sed "s/[#\"]//g"|cut -d'=' -f2-`
    fi
    for pp in ${PORTS_LIST}; do
        #echo "$pp"
        port_pair=`echo $pp |  tr -d ' ' `
        if [ ! "$port_pair" == "" ]; then
            # -p ${local_dockerPort1}:${dockerPort1} 
            host_port=`echo $port_pair | tr -d ' ' | cut -d':' -f1`
            docker_port=`echo $port_pair | tr -d ' ' | cut -d':' -f2`
            PORT_MAP="${PORT_MAP} -p ${host_port}:${docker_port}"
        fi
    done
}
#### ---- Generate Port Mapping ----
generatePortMapping
echo ${PORT_MAP}

###################################################
#### ---- Function: Generate privilege String  ----
####      (Don't change!)
###################################################
privilegedString=""
function generatePrivilegedString() {
    OS_VER=`which yum`
    if [ "$OS_VER" == "" ]; then
        # Ubuntu
        echo "Ubuntu ... not SE-Lunix ... no privileged needed"
    else
        # CentOS/RHEL
        privilegedString="--privileged"
    fi
}
generatePrivilegedString
echo ${privilegedString}

###################################################
#### ---- Mostly, you don't need change below ----
###################################################
function cleanup() {
    if [ ! "`docker ps -a|grep ${instanceName}`" == "" ]; then
         docker rm -f ${instanceName}
    fi
}

function displayURL() {
    port=${1}
    echo "... Go to: http://${MY_IP}:${port}"
    #firefox http://${MY_IP}:${port} &
    if [ "`which google-chrome`" != "" ]; then
        /usr/bin/google-chrome http://${MY_IP}:${port} &
    else
        firefox http://${MY_IP}:${port} &
    fi
}

###################################################
#### ---- Replace "Key=Value" withe new value ----
###################################################
function replaceKeyValue() {
    inFile=${1:-${DOCKER_ENV_FILE}}
    keyLike=$2
    newValue=$3
    if [ "$2" == "" ]; then
        echo "**** ERROR: Empty Key value! Abort!"
        exit 1
    fi
    sed -i -E 's/^('$keyLike'[[:blank:]]*=[[:blank:]]*).*/\1'$newValue'/' $inFile
}
#### ---- Replace docker.env with local user's UID and GID ----
replaceKeyValue ${DOCKER_ENV_FILE} "USER_ID" "$(id -u $USER)"
replaceKeyValue ${DOCKER_ENV_FILE} "GROUP_ID" "$(id -g $USER)"

## -- transform '-' and space to '_' 
#instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/\-: " "_"`
instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/: " "_"`

echo "---------------------------------------------"
echo "---- Starting a Container for ${imageTag}"
echo "---------------------------------------------"

cleanup

#### run restart options: { no, on-failure, unless-stopped, always }
RESTART_OPTION=no

echo ${DISPLAY}
xhost +SI:localuser:$(id -un) 
DISPLAY=${MY_IP}:0 \
docker run -it \
    --name=${instanceName} \
    --restart=${RESTART_OPTION} \
    ${privilegedString} \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --user $(id -u $USER) \
	--network host \
    ${VOLUME_MAP} \
    ${PORT_MAP} \
    ${imageTag} $*

cleanup

