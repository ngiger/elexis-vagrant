#!/bin/bash
# Copyright 2013 by Niklaus Giger niklaus.giger@member.fsf.org
# Just download it using wget/curl https://raw.github.com/ngiger/elexis-vagrant/master/bootstrap_ubuntu_12_04.sh
# and execute it afterwards. E.g sudo -i $PWD/bootstrap_ubuntu_12_04.sh

# For Peter Schönbucher I needed to install an ubuntu 12.04 desktop 
# To share the the puppet with it master I add the following two lines to /etc/fstat
#   192.168.1.222:/etc/puppet       /etc/puppet     nfs     defaults        0       2
#  192.168.1.222:/etc/hiera        /etc/hiera      nfs     defaults        0       2
# then ran sudo mount -a


debInst()
{
    dpkg-query -Wf'${db:Status-abbrev}' "${1}" 2>/dev/null | grep -q '^i'
}

packets_needed="curl git openssh-server openssh-client" #  virtualbox virtualbox-dkms
for j in $packets_needed
do
  if debInst $j; then
      echo $j seems to be already installed
  else
      apt-get -qqy install  $j
  fi
done

origin='git://github.com/ngiger/elexis-vagrant.git'
dest='/etc/puppet'
if [[ -d ${dest}/.git ]]
then
  echo "${dest} has already a .git directory. Therefore we don't reinstall it"
else
  echo "Installing into ${dest}"
  if ! [[ -d /etc/puppet/ ]]
  then
    operation='Cloned'
    git clone ${origin} ${dest}
  elif [[ -d /etc/puppet/.git ]]
  then
    operation='Pulled'
    cd  ${dest}
    git pull
  else
    # move it out of the way
    operation='Cloned after moving it out of the way'
    tempDir=`mktemp -d`
    mv ${dest} ${tempDir}
    git clone ${origin} ${dest}
    mv --no-clobber ${tempDir}/* ${dest}
  fi
fi

echo "(Re)installing needed packets for ruby1.9"
apt-get -qqy --no-install-recommends install bash curl git patch bzip2  \
  build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev \
  libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf \
  libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion libffi-dev libvirt-dev \
  ruby1.9.1 ruby1.9.1-dev augeas-tools libaugeas-ruby1.9.1
apt-get -qqy --no-install-recommends build-dep ruby1.9.1

apt-get remove python3-software-properties # remove cruft from the cloud image which breaks kde
shell/install_puppet.sh

echo "${operation} ${origin} into ${dest}"