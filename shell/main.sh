#!/bin/bash 

# Directory in which librarian-puppet should manage its modules directory
if [ -d /vagrant ] ; then PUPPET_DIR=/vagrant ; else PUPPET_DIR=/etc/puppet ; fi
if [ ! -d /vagrant ] ; then cp /vagrant/Puppetfile $PUPPET_DIR ; fi

export rvm_trust_rvmrcs_flag=1
cd $PUPPET_DIR

# we want to use rvm and puppet installed via gem as the
# puppet installed via apt has hiera 1.1 and therefore chokes
# when seening %{::environment} in its configuration
apt-get update 
apt-get remove  --quiet --assume-yes puppet
apt-get install --quiet --assume-yes ruby ruby-dev libaugeas-ruby 
export PATH=/usr/local/bin:$PATH
source /usr/local/rvm/scripts/rvm
rvm use system --default 

# we must have puppet install or we cannot call vagrant up
if [ "$(gem search -i puppet)" = "false" ]; then
  gem install --no-ri --no-rdoc puppet
  cd $PUPPET_DIR && puppet install --clean
fi

# Initialize /etc/puppet/hiera.yaml
if [ $? -eq 0  ] ; then
  export HIERA_DATA=/`df -h | grep hieradata | cut -d / -f 2-`
  if [ ! -L /etc/puppet/hiera.yaml ] ; then ln -s $HIERA_DATA/hiera.yaml /etc/puppet/hiera.yaml; fi
  if [ ! -L /etc/hiera.yaml ]        ; then ln -s $HIERA_DATA/hiera.yaml /etc/hiera.yaml; fi
fi

# Next is only necessary as librarian-puppet (0.9.8) cannot handle puppetlabs/postgresql
if [ -d modules/postgresql ] ; then
  puppet module install --modulepath modules puppetlabs/postgresql 
fi

dpkg -l etckeeper | grep ii
if [ $? -ne 0  ] ; then
  apt-get install --quiet --assume-yes git etckeeper
fi