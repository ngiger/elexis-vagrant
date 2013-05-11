#!/bin/bash 

# Directory in which librarian-puppet should manage its modules directory
if [ -d /vagrant ] ; then PUPPET_DIR=/vagrant ; else PUPPET_DIR=/etc/puppet ; fi
if [ ! -d /vagrant ] ; then cp /vagrant/Puppetfile $PUPPET_DIR ; fi

export rvm_trust_rvmrcs_flag=1
cd $PUPPET_DIR

# we want to use rvm and puppet installed via gem as the
# puppet installed via apt has hiera 1.1 and therefore chokes
# when seening %{::environment} in its configuration
grep puppet /etc/.gitignore | grep puppet
if [ $? -ne 0  ] ; then
  echo puppet/ >> /etc/.gitignore
fi

apt-get update 
apt-get remove    --quiet --assume-yes    puppet
apt-get upgrade   --quiet --assume-yes
apt-get install   --quiet --assume-yes    ruby ruby-dev libaugeas-ruby ruby-shadow linux-headers-amd64

# we don't want to be in a directory where a .rvmrc lays aout

pwd
# we must have puppet install or we cannot call vagrant up
if [ "$(gem search -i puppet)" = "false" ]; then
  gem install --no-ri --no-rdoc puppet
  cd $PUPPET_DIR && puppet install --clean
fi

# Initialize /etc/puppet/hiera.yaml
df -h | grep hieradata
if [ $? -eq 0  ] ; then
  export HIERA_DATA=/`df -h | grep hieradata | cut -d / -f 2-`
  if [ ! -L /etc/puppet/hiera.yaml ] ; then ln -s $HIERA_DATA/hiera.yaml /etc/puppet/hiera.yaml; fi
  if [ ! -L /etc/hiera.yaml ]        ; then ln -s $HIERA_DATA/hiera.yaml /etc/hiera.yaml; fi
fi

dpkg -l etckeeper | grep ii
if [ $? -ne 0  ] ; then
  apt-get install --quiet --assume-yes git etckeeper &> /var/log/etckeeper.log
fi

