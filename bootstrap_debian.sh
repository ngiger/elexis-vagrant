#!/bin/bash
# Copyright 2013 by Niklaus Giger niklaus.giger@member.fsf.org
# Just download it using wget/curl https://raw.github.com/ngiger/elexis-vagrant/with_hiera/bootstrap_debian.sh
# and execute it afterwards. E.g sudo -i $PWD/bootstrap_debian.sh

debInst()
{
    dpkg-query -Wf'${db:Status-abbrev}' "${1}" 2>/dev/null | grep -q '^i'
}

packets_needed="curl git virtualbox virtualbox-dkms"
for j in $packets_needed
do
  if debInst $j; then
      echo $j seems to be already installed
  else
      apt-get install $j
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

echo "(Re)installing needed packets for RVM and ruby"
apt-get --no-install-recommends install sudo curl
RVM_MULTI_PATH='/usr/local/rvm/bin/rvm'
if [[ -e $RVM_MULTI_PATH ]]
then
  echo "$RVM_MULTI_PATH already installed"
else
  echo "Installing rvm as multi user into $RVM_MULTI_PATH"
  curl -L https://get.rvm.io | sudo bash -s stable
fi

echo "(Re)installing needed packets for RVM and ruby"
apt-get --no-install-recommends install bash curl git patch bzip2 \
  build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev \
  libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf \
  libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion libffi-dev libvirt-dev

rvm install 1.9.2
gem install --no-ri --no-rdoc puppet

HIERA_PUPPET_YAML='/etc/puppet/hiera.yaml'
if [[ -f ${HIERA_PUPPET_YAML} ]]
then
  echo "${HIERA_PUPPET_YAML} already present"
else
  echo "Adding default configuration into ${HIERA_PUPPET_YAML}"
(
cat <<EOF
---
:backends: yaml
:yaml:
  :datadir: ${dest}
:hierarchy:
  - %{::clientcert}
  - %{::environment}
  - private_hiera/config
  - hiera/common
:logger: console
EOF
) > $HIERA_PUPPET_YAML
fi

HIERA_YAML='/etc/hiera.yaml'
if [[ ${HIERA_YAML} ]]
then
  echo "${HIERA_YAML} already present"
else
  echo "Creating logical link from ${HIERA_PUPPET_YAML} -> ${HIERA_YAML}"
  ln -s ${HIERA_PUPPET_YAML} ${HIERA_YAML}
fi
ln -s ${HIERA_PUPPET_YAML} ${HIERA_YAML}
ls -l ${HIERA_PUPPET_YAML} ${HIERA_YAML}

echo "Cloned ${origin} into ${dest} and created default hiera configuration in ${HIERA_PUPPET_YAML}"