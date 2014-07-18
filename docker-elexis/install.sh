#!/bin/bash -v
# Here we install all the stuff needed to run a Jenkins-CI slave to 
# build elexis and/or run the Jubula GUI tests

apt-get update && apt-get  upgrade -y

# Install stuff needed for vagrant and conveniences
apt-get install -y --no-install-recommends augeas-tools curl git htop libaugeas-ruby lsb net-tools sudo vim ruby ruby1.9.1-dev rubygems build-essential

# Add user vagrant to the image
adduser --quiet vagrant

# Set password for the vagrant user (you may want to alter this).
echo "vagrant:vagrant" | chpasswd

# install vagrant
cd /var/tmp 
wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
dpkg -i vagrant_1.6.3_x86_64.deb

# install puppet
echo "gem: --no-rdoc --no-ri" > /etc/gemrc
gem install puppet --version 3.6.2
gem install librarian-puppet --version 1.1.2
  
# Clean up APT when done.
apt-get clean 
# && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
