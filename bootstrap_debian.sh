#!/bin/bash
# Copyright 2013 by Niklaus Giger niklaus.giger@member.fsf.org

if [[ -d /etc/puppet/.git ]]
then
  echo "/etc/puppet has already a .git directory. Therefore we don't reinstall it"
  exit
else
  echo "Installing into /etc/puppet"
fi

debInst()
{
    dpkg-query -Wf'${db:Status-abbrev}' "${1}" 2>/dev/null | grep -q '^i'
}

packets_needed="curl git virtualbox virtualbox-dkms"
for j in $packets_needed
do
  echo "j ist $j"
  if debInst $j; then
      echo $j seems to be already installed
  else
      apt-get install $j
  fi
done

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
  libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion libffi-dev

. ~/.bash_profile # activate rvm  
rvm install 1.9.2
gem install --no-ri --no-rdoc puppet
