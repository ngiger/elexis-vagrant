# prerequisite
# mkdir ssh && ssh-keygen -f ssh/id_rsa -q -N ""
# wget http://mirror.switch.ch/eclipse/technology/epp/downloads/release/luna/SR1/eclipse-rcp-luna-SR1-linux-gtk-x86_64.tar.gz
# tar -xzvf eclipse-rcp-luna-SR1-linux-gtk-x86_64.tar.gz
# sudo apt-get install docker.io -t sid
# you must be in the docker group
#
# FROM     debian:wheezy
FROM     ubuntu:12.04
MAINTAINER Niklaus Giger

RUN apt-get update
RUN apt-get install -y openjdk-7-jdk
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

EXPOSE 22
ADD ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys
ADD eclipse /root/eclipse/
# tried to get the web browser work
# RUN apt-get install -y libwebkitgtk-3.0-0
# RUN apt-get install -y firefox
# RUN apt-get install -y icedtea-7-plugin firefox
# RUN apt-get install -y libswt-webkit-gtk-3-jni libwebkitgtk-3.0-0 libwebkitgtk-1.0-0 libswt-webkit-gtk-3-jni

RUN apt-get install -y libswt-webkit-gtk-3-jni libwebkitgtk-3.0-0
CMD ['/usr/sbin/update-java-alternatives', '--set', 'java-1.7.0-openjdk-amd64']
CMD ["/usr/sbin/sshd", "-D"]
ADD readme.textile /root/readme.textile
# docker build -t ngiger/luna-demo .
# now the Eclipse menu Help.."Help Contents" shows in an internal web browser