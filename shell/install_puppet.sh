#!/bin/bash 

# Directory in which librarian-puppet should manage its modules directory
if [ -d /vagrant ] ; then PUPPET_DIR=/vagrant ; else PUPPET_DIR=/etc/puppet ; fi
if [ ! -d /vagrant ] ; then cp /vagrant/Puppetfile $PUPPET_DIR ; fi

cd $PUPPET_DIR

grep puppet /etc/.gitignore | grep puppet
if [ $? -ne 0  ] ; then
  echo puppet/ >> /etc/.gitignore
fi

code_name=`lsb_release -c | cut -f2`
wget https://apt.puppetlabs.com/puppetlabs-release-${code_name}.deb
sudo dpkg -i puppetlabs-release-${code_name}.deb
sudo apt-get update
sudo apt-get install -y git puppet-common=3.6.1-1puppetlabs1 puppet=3.6.1-1puppetlabs1 hiera=1.3.4-1puppetlabs1
sudo gem install librarian-puppet --version=1.3.1 --no-ri --no-rdoc
df -h | grep hieradata

