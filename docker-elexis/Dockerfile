# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
# Some ideas taken from https://github.com/evarga/docker-images/blob/master/jenkins-slave/Dockerfile
#
# Additions:
#  * Add my local APT-proxy
#  * xvfb, xvfb, sudo
#  * install jubula found at /opt/downloads/jubula_8.0/installer-jubula_linux-gtk-x86_64.sh (from bredex)
#
# To install docker on a debian/wheezy machine use
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
# sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
# apt-get update -y
# apt-get install lxc-docker -y
#
# remove superfluos images
# docker rmi $(docker images -f "dangling=true" -q)
# force clean build
# docker build --no-cache .
FROM ngiger/baseimage-wheezy:0.9.0
MAINTAINER Niklaus Giger "niklaus.giger@member.fsf.org"

ENV DEBIAN_FRONTEND noninteractive

RUN echo 'Acquire::http::Proxy "http://172.25.1.70:3142";' >  /etc/apt/apt.conf.d/proxy

RUN mkdir -p    /build
ADD install.sh  /build/
RUN /build/install.sh

