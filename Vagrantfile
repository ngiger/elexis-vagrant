#!/usr/bin/ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'pp'
#------------------------------------------------------------------------------------------------------------
# Some simple customization below
#------------------------------------------------------------------------------------------------------------
boxId = 'Elexis-Wheezy-amd64-20130510'
private = "/opt/src/veewee-elexis/#{boxId}.box"
private = "/opt/images/#{boxId}.box"
boxUrl = File.exists?(private) ? private : "http://ngiger.dyndns.org/downloads/#{boxId}.box"
boxUrl = 'docker'
puts "Using boxUrl #{boxUrl}"

bridgedNetworkAdapter = "eth0" # adapt it to your liking, e.g. on MacOSX it might 
# bridgedNetworkAdapter = "en0: Wi-Fi (AirPort)" # adapt it to your liking, e.g. on MacOSX it might 

# Allows you to select the VMs to boot
# systemsToBoot = [ :server, :backup, :devel, :arzt, :jenkins ]
systemsToBoot = [ :server ]

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
# require 'socket'
# hostname = Socket.gethostname
# domain = hostname.split('.')[-2..-1].join('.')
Vagrant.configure("2") do |config|
  config.vm.box_url = "dummy"
  config.vm.network :public_network
end

#       # https://github.com/phusion/baseimage-docker/blob/master/README.md#login

Vagrant.configure("2") do |config|
#  config.cache.scope = :machine
  config.ssh.username = "root"
  config.ssh.private_key_path = "insecure_key"
  config.vm.provision "puppet"
  config.vm.provision "puppet" do |puppet|
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
    puppet.module_path = "modules"
    puppet.manifest_file  = "site.pp" # works, but cannot use a directory
    puppet.working_directory = '/vagrant/'
#    puppet.options = "--verbose --debug --noop"
    puppet.options = "--verbose --noop --debug"
  end
  
  # Knoten ubuntu wenn clients (aka Benutzer) damit arbeiten sollen
  config.vm.define 'ubuntu' do |node|
    node.vm.provider "ubuntu" do |d|
      d.image = "phusion/baseimage:0.9.9" # does not come up as it should
      # https://github.com/phusion/baseimage-docker/blob/master/README.md#login
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"] 
      d.has_ssh = true
      d.vagrant_machine = 'ubuntu'
      d.name = 'ubuntu'
    end
  end

  # Knoten mit net-server (dnsmasq, dhcp, x2gothinclients)
  config.vm.define 'net-server', primary: true do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "net-server.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'net-server'
    end 
  end

  # Knoten mit master-db
  config.vm.define 'db-master', primary: true do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "db-master.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'db-master'
    end 
  end

  # Knoten mit backup-db
  config.vm.define 'db-backup', primary: true do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "db-backup.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'db-backup'
    end 
  end


  # Knoten server der alten All-In-One Server abbildet
  config.vm.define 'server', primary: true do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "server.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'server'
    end 
  end

end

