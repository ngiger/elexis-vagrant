#!/bin/bash
# Copyright 2013 by Niklaus Giger niklaus.giger@member.fsf.org
# Just download it using wget/curl https://raw.github.com/ngiger/elexis-vagrant/with_hiera/bootstrap_debian.sh
# and execute it afterwards. E.g sudo -i $PWD/bootstrap_debian.sh

debInst()
{
    dpkg-query -Wf'${db:Status-abbrev}' "${1}" 2>/dev/null | grep -q '^i'
}

if [[ -d /vagrant ]]
then
  echo "We seem to be running inside a vagrant VM"
else
  packets_needed="curl git virtualbox virtualbox-dkms"
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
      git clone ${origin} ${dest}
    else
      # move it out of the way
      tempDir=`mktemp -d`
      mv ${dest} ${tempDir}
      git clone ${origin} ${dest}
      mv --no-clobber ${tempDir}/* ${dest}
    fi
  fi
fi

echo "(Re)installing needed packets for ruby1.9"
# openssl
# here we should stop the services without asking
# and we should not reinstall grub!
# sudo apt-get upgrade --yes
INST="sudo apt-get install --yes --quiet --no-install-recommends"
$INST  bash curl git patch bzip2  
$INST   build-essential libreadline6 libreadline6-dev curl git-core
# zlib1g zlib1g-dev  libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf \
#  libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion libffi-dev libvirt-dev \
$INST ruby1.9.1 ruby1.9.1-dev augeas-tools libaugeas-ruby1.9.1
sudo apt-get -qqy --no-install-recommends build-dep ruby1.9.1

shell/install_puppet.sh
sudo gem install --no-ri --no-rdoc bundler

echo "${operation} ${origin} into ${dest}"
