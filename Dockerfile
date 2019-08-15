FROM hoonti06/docker-jdk-x11

MAINTAINER hoonti06 "hoonti06@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# ref: https://github.com/dockerfile/java/tree/master/oracle-java8

## -------------------------------------------------------------------------------
## ---- USER is defined in parent image: hoonti06/docker-jdk-x11 already ----
## -------------------------------------------------------------------------------
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}
ENV ECLIPSE_WORKSPACE=${HOME}/eclipse-workspace

## ----------------------------------------------------------------------------
## ---- To change to different Eclipse version: e.g., oxygen, change here! ----
## ----------------------------------------------------------------------------

## -- 1.) Eclipse version: 2019-06, oxygen, photon, etc.: -- ##
ARG ECLIPSE_VERSION=${ECLIPSE_VERSION:-2019-06}
ENV ECLIPSE_VERSION=${ECLIPSE_VERSION}

## -- 2.) Eclipse Type: -- ##
# Refer the Type to access http://mirror.math.princeton.edu/pub/eclipse/technology/epp/downloads/release/photon/R/
# Type : jee, cpp, java, javascript, dsl, php, rust, committers, modeling, parallel, rcp, reporting, scout, testing
# Ex> ARG ECLIPSE_TYPE=${ECLIPSE_TYPE:-modeling}
ARG ECLIPSE_TYPE=${ECLIPSE_TYPE:-jee}

## -- 3.) Eclipse Release: -- ##
# Ex> ARG ECLIPSE_RELEASE=${ECLIPSE_RELEASE:-2}
ARG ECLIPSE_RELEASE=${ECLIPSE_RELEASE:-R}

## -- 4.) Eclipse Download Mirror site: -- ##
#ARG ECLIPSE_OS_BUILD=${ECLIPSE_OS_BUILD:-win32-x86_64}
ARG ECLIPSE_OS_BUILD=${ECLIPSE_OS_BUILD:-linux-gtk-x86_64}

## -- 5.) Eclipse Download Mirror site: -- ##
#http://mirror.math.princeton.edu/pub/eclipse/technology/epp/downloads/release/photon/R/eclipse-jee-photon-R-linux-gtk-x86_64.tar.gz
#http://mirror.math.princeton.edu/pub/eclipse/technology/epp/downloads/release/photon/R/eclipse-modeling-photon-R-linux-gtk-x86_64.tar.gz
ARG ECLIPSE_MIRROR_SITE_URL=${ECLIPSE_MIRROR_SITE_URL:-http://mirror.math.princeton.edu}

## ----------------------------------------------------------------------------------- ##
## ----------------------------------------------------------------------------------- ##
## ----------- Don't change below unless Eclipse download system change -------------- ##
## ----------------------------------------------------------------------------------- ##
## ----------------------------------------------------------------------------------- ##
## -- Eclipse TAR/GZ filename: -- ##
#ARG ECLIPSE_TAR=${ECLIPSE_TAR:-eclipse-jee-photon-R-linux-gtk-x86_64.tar.gz}
ARG ECLIPSE_TAR=${ECLIPSE_TAR:-eclipse-${ECLIPSE_TYPE}-${ECLIPSE_VERSION}-${ECLIPSE_RELEASE}-${ECLIPSE_OS_BUILD}.tar.gz}

## -- Eclipse Download route: -- ##
ARG ECLIPSE_DOWNLOAD_ROUTE=${ECLIPSE_DOWNLOAD_ROUTE:-pub/eclipse/technology/epp/downloads/release/${ECLIPSE_VERSION}/${ECLIPSE_RELEASE}}

## -- Eclipse Download full URL: -- ##
# Ref> http://mirror.math.princeton.edu/pub/eclipse/technology/epp/downloads/release/photon/R/
# Ref> http://mirror.math.princeton.edu/pub/eclipse/technology/epp/downloads/release/photon/R/
ARG ECLIPSE_DOWNLOAD_URL=${ECLIPSE_DOWNLOAD_URL:-${ECLIPSE_MIRROR_SITE_URL}/${ECLIPSE_DOWNLOAD_ROUTE}}

## http://ftp.osuosl.org/pub/eclipse/technology/epp/downloads/release/photon/R/eclipse-jee-photon-R-linux-gtk-x86_64.tar.gz
## http://mirror.math.princeton.edu/pub/eclipse/technology/epp/downloads/release/photon/R/eclipse-jee-photon-R-linux-gtk-x86_64.tar.gz
## http://mirror.math.princeton.edu/pub/eclipse/technology/epp/downloads/release/photon/R/eclipse-modeling-photon-R-linux-gtk-x86_64.tar.gz
WORKDIR /opt
RUN sudo wget -c ${ECLIPSE_DOWNLOAD_URL}/${ECLIPSE_TAR} && \
    sudo tar xvf ${ECLIPSE_TAR} && \
    sudo rm ${ECLIPSE_TAR} 

#################################
#### Install Eclipse Plugins ####
#################################
# ... add Eclipse plugin - installation here (see example in https://github.com/DrSnowbird/papyrus-sysml-docker)

# Ex> plugin 'vrapper' install (Actually NOT working)
#RUN cd /opt/eclipse && \
#	./eclipse -nosplash \
#		-application org.eclipse.equinox.p2.director \
#		-profile SDKProfile \
#		-destination $HOME/.eclipse \
#		-repository http://download.eclipse.org/releases/photon,http://vrapper.sourceforge.net/update-site/stable \
#		-installIU net.sourceforge.vrapper.feature.group \
#		-installIU net.sourceforge.vrapper.eclipse.jdt.feature.feature.group \
#		-installIU net.sourceforge.vrapper.plugin.surround.feature.group

RUN sudo apt-get update -y && sudo apt-get install -y libwebkitgtk-3.0-0

##################################
#### Set up user environments ####
##################################
VOLUME ${ECLIPSE_WORKSPACE}
VOLUME ${HOME}/.eclipse 

ARG GROUP_ID=1000
ARG USER_ID=1000

RUN mkdir -p ${HOME}/.eclipse ${ECLIPSE_WORKSPACE} &&\
    sudo chown -R ${USER}:${USER} ${ECLIPSE_WORKSPACE} ${HOME}/.eclipse
    
USER ${USER}
WORKDIR ${ECLIPSE_WORKSPACE}
CMD ["/opt/eclipse/eclipse"]

