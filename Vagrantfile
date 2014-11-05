#!/usr/bin/env ruby
# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

todo = %(
  +# https://forge.puppetlabs.com/puppetlabs/stdlib
+# file_line: This resource ensures that a given line is contained within a file. You can also use "match" to replace existing lines.
+# loadyaml Load a YAML file containing an array, string, or hash, and return the data in the corresponding native data type.
+#  str2saltedsha512 This converts a string to a salted-SHA512 password hash (which is used for OS X versions >= 10.7). Given any simple string, you will get a hex ve
+# unix chpasswd [options] DESCRIPTION     The chpasswd command reads a list of user name and password pairs from standard input and uses this information to update a
+# Each line is of the format:
+# user_name:password
)
if ARGV.index('provision')
  ENV['RUBYOPT']=''
#  system("librarian-puppet install --verbose")
end

#------------------------------------------------------------------------------------------------------------
# Some simple customization below
#------------------------------------------------------------------------------------------------------------
boxId = 'Elexis-Wheezy-amd64-20130510'
private = "/opt/src/veewee-elexis/#{boxId}.box"
boxUrl = File.exists?(private) ? private : "http://ngiger.dyndns.org/downloads/#{boxId}.box"
puts "Using boxUrl #{boxUrl}"

bridgedNetworkAdapter = "eth0" # adapt it to your liking, e.g. on MacOSX it might
# bridgedNetworkAdapter = "en0: Wi-Fi (AirPort)" # adapt it to your liking, e.g. on MacOSX it might

# Allows you to select the VMs to boot
# systemsToBoot = [:server, :ubuntu, :backup, :jenkins, :arzt, :devel]
systemsToBoot = [:server, :ubuntu]

# Patch the next lines if you have more than one elexis-vagrant running in your network
firstPort       = 20000
macFirst2Bytes  = '0000'

#------------------------------------------------------------------------------------------------------------
# End of simple customization
#------------------------------------------------------------------------------------------------------------
# All Vagrant configuration is done here. The most common configuration
# options are documented and commented below. For a complete reference,
# please see the online documentation at vagrantup.com.

# A good solution would be http://serverfault.com/questions/418422/public-static-ip-for-vagrant-boxes

Vagrant.configure("2") do |config|
  config.vm.network "public_network", bridge: 'br0'
  puts "Using boxUrl #{boxUrl}"
  config.vm.provision :shell, :path => "shell/install_puppet.sh"
#  config.vm.provision :shell, inline: "/usr/bin/puppet apply --confdir=/vagrant /vagrant/manifests/site.pp --verbose --debug"
  config.vm.provider "virtualbox" do |v|
    v.gui = true
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.provision :puppet do |puppet|
    puppet.options = ['--environment', 'development']
#    puppet.options = "--verbose --debug"
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/vagrant"
    # puppet.facter = { "vagrant" => "1"  }
  end

  config.vm.define :server do |server|
    server.vm.host_name = "server.#{`hostname -d`.chomp}"
    server.vm.network :public_network, { :mac => macFirst2Bytes + '27226F02', :bridge => bridgedNetworkAdapter }
    # server.vm.box     = 'puppetlabs/debian-7.6-64-puppet' # missing gues additions
    # server.vm.box     = 'debian-73-x64-virtualbox-puppet'
    # server.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/debian-73-x64-virtualbox-puppet.box'
    server.vm.box     = boxId
    server.vm.box_url = boxUrl
    server.vm.network "forwarded_port", guest: 80, host: 8080
    server.vm.network "forwarded_port",  guest:    80, host: firstPort +  80    # Apache
    server.vm.network "forwarded_port",  guest:  3306, host: firstPort + 306    # MySQL
    server.vm.network "forwarded_port",  guest:  4567, host: firstPort + 567    # Gollum (elexis-admin Wiki)
    server.vm.network "forwarded_port",  guest:  9393, host: firstPort + 393    # elexis-cockpit
  end if systemsToBoot.index(:server)

  config.vm.define :backup do |backup|
    backup.vm.host_name = "backup.#{`hostname -d`.chomp}"
    backup.vm.network :public_network, { :mac => macFirst2Bytes + '37226F02', :bridge => bridgedNetworkAdapter }
    backup.vm.box     = boxId
    backup.vm.box_url = boxUrl
    backup.vm.network "forwarded_port",  guest:   22, host:  firstPort + 1022    # ssh
    backup.vm.network "forwarded_port",  guest:   80, host:  firstPort + 1080    # Apache
    backup.vm.network "forwarded_port",  guest: 3306, host:  firstPort + 1306    # MySQL
    backup.vm.network "forwarded_port",  guest: 4567, host:  firstPort + 1567    # Gollum (elexis-admin Wiki)
    backup.vm.network "forwarded_port",  guest: 9393, host:  firstPort + 1393    # elexis-cockpit
  end if systemsToBoot.index(:backup)

  config.vm.define :devel do |devel|
    devel.vm.host_name = "devel.#{`hostname -d`.chomp}"
    devel.vm.network :public_network, { :mac => macFirst2Bytes + '47226F02', :bridge => bridgedNetworkAdapter }
    devel.vm.box     = boxId
    devel.vm.box_url = boxUrl
    devel.vm.network "forwarded_port",  guest:   22, host:  firstPort + 2022    # ssh
    devel.vm.network "forwarded_port",  guest:   80, host:  firstPort + 2080    # Apache
    devel.vm.network "forwarded_port",  guest: 8080, host:  firstPort + 2888    # Jenkins
  end if systemsToBoot.index(:devel)

  config.vm.define :arzt do |arzt|
    arzt.vm.host_name = "arzt.#{`hostname -d`.chomp}"
    arzt.vm.network :public_network, { :mac => macFirst2Bytes + '57226F02', :bridge => bridgedNetworkAdapter }
    arzt.vm.box     = "Elexis-Wheezy-amd64"
    arzt.vm.box_url = boxUrl
    arzt.vm.network "forwarded_port",  guest: 22, host:  firstPort + 3022    # ssh
  end if systemsToBoot.index(:arzt)

  config.vm.define :jenkins do |jenkins|
    jenkins.vm.host_name = "jenkins.#{`hostname -d`.chomp}"
    jenkins.vm.network :public_network, { :mac => macFirst2Bytes + '67227F02', :bridge => bridgedNetworkAdapter }
    jenkins.vm.box     = boxId
    jenkins.vm.box_url = boxUrl
    jenkins.vm.network "forwarded_port",  guest:   22, host:  firstPort + 7022    # ssh
    jenkins.vm.network "forwarded_port",  guest:   80, host:  firstPort + 7080    # Apache
    jenkins.vm.network "forwarded_port",  guest: 8080, host:  firstPort + 7888    # Jenkins
  end if systemsToBoot.index(:jenkins)

  config.vm.define :ubuntu do |ubuntu|
    ubuntu.vm.host_name = "ubuntu.#{`hostname -d`.chomp}"
    ubuntu.vm.network :public_network, { :mac => macFirst2Bytes + '27228F02', :bridge => bridgedNetworkAdapter }
    ubuntu.vm.box    = 'ubuntu/trusty64'
    ubuntu.vm.network "forwarded_port",  guest:  22, host:  firstPort + 8222    # ssh
    ubuntu.vm.network "forwarded_port",  guest:  80, host:  firstPort + 8080    # Apache
    ubuntu.vm.network "forwarded_port",  guest:8080, host:  firstPort + 8888    # Jenkins
  end if systemsToBoot.index(:ubuntu)


end
