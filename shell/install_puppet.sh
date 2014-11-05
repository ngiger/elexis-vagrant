#!/bin/bash

# Directory in which librarian-puppet should manage its modules directory
if [ -d /vagrant ] ; then PUPPET_DIR=/vagrant ; else PUPPET_DIR=/etc/puppet ; fi
if [ ! -d /vagrant ] ; then cp /vagrant/Puppetfile $PUPPET_DIR ; fi

cd $PUPPET_DIR

grep puppet /etc/.gitignore | grep puppet
if [ $? -ne 0  ] ; then
  echo puppet/ >> /etc/.gitignore
  echo hiera >> /etc/.gitignore
  echo hiera.repo >> /etc/.gitignore
fi

version=`puppet --version | grep 3.6.1`
if [ "$version" == "3.6.1" ] ; then echo "Puppet 3.6.1 already installed"; exit;
else
  echo "Must install as version is $version"
fi

# ensure that we dont have an (older) version of puppet installed as gem
sudo gem uninstall --all --quiet hiera puppet
code_name=`lsb_release -c | cut -f2`
wget https://apt.puppetlabs.com/puppetlabs-release-${code_name}.deb
sudo dpkg -i puppetlabs-release-${code_name}.deb
sudo apt-get update
sudo apt-get install -y --force-yes git puppet-common=3.6.1-1puppetlabs1 hiera=1.3.4-1puppetlabs1  puppet=3.6.1-1puppetlabs1
# I think I don't need librarian-puppet
#sudo apt-get install -y ruby-dev
#sudo gem install librarian-puppet --version=2.0.0 --no-ri --no-rdoc


