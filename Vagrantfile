#!/usr/bin/ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'pp'
require 'socket'
# should we use https://github.com/mhahn/vagrant-librarian-puppet
# vagrant plugin install vagrant-librarian-puppet
# vagrant plugin list
# https://puphpet.com

#------------------------------------------------------------------------------------------------------------
# Open problems
#------------------------------------------------------------------------------------------------------------
# why does vagrant up not provision correctly after vagrant halt? Does vagrant halt not stop the docker. Or the process pick up exactly as before
# ensure that database, dnsmasq start at bringing up
# net_server takes about 8 minutes to provision
# postgres is running but not dnsmasq. Calling "/etc/init.d/dnsmasq start" fixes the problem
# samba does not correct read_only for shares! http://stackoverflow.com/questions/18428930/augeas-set-value-with-whitespace-failed

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
# systemsToBoot = [ :server, :db_backup, :db_master, :devel, :arzt, :jenkins, :ubuntu ]
systemsToBoot = [ :server ] # , :server ]

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
  # config.librarian_puppet.puppetfile_dir = 'puppet'
  # config.librarian_puppet.resolve_options = { :force => true }
end

#       # https://github.com/phusion/baseimage-docker/blob/master/README.md#login
Vagrant.configure("2") do |config|
  config.vm.provision :shell, :path => "before_puppet.sh"
  config.vm.provision "puppet" do |puppet|
    puppet.facter = {
      "vagrant" => "1"
    }
  end
end

Vagrant.configure("2") do |config|
  config.ssh.username = "root"
  config.ssh.private_key_path = "insecure_key"
  config.librarian_puppet.puppetfile_dir = "puppetXX"
  config.vm.provision "puppet"
  config.vm.provision "puppet" do |puppet|
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
    puppet.manifest_file  = "site.pp" # works, but cannot use a directory
    puppet.working_directory = '/vagrant/'
#    puppet.options = "--verbose --debug --noop"
    puppet.options = "--verbose --debug"
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
  end if systemsToBoot.index(:ubuntu)

  # Knoten mit master-db
  config.vm.define 'db_master' do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "db_master.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'db_master'
    end 
  end if systemsToBoot.index(:db_master)

  # Knoten mit backup-db
  config.vm.define 'db_backup' do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "db_backup.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'db_backup'
    end 
  end if systemsToBoot.index(:db_backup)

  # Knoten mit net_server (dnsmasq, dhcp, x2gothinclients)
  # http://stackoverflow.com/questions/23012273/setting-up-docker-dnsmasq
  # sudo docker run -v="$(pwd)/dnsmasq.hosts:/dnsmasq.hosts" --name=$name -p=$MY_IP:53:5353/udp -d sroegner/dnsmasq      
  ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
  my_ip = ip.ip_address if ip
  puts "my_ip ist #{my_ip}"
  config.vm.define 'net_server', primary: true do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.network "forwarded_port", guest: 80, host: 8080
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "net_server.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"] #, "-v='$(pwd)/dnsmasq.hosts:/dnsmasq.hosts'"#, "-p=#{my_ip}:53:5353/udp"]
      d.ports = [ '53:5353' ]
      # config.vm.synced_folder "src/", "/srv/website"
      config.vm.synced_folder "#{Dir.pwd}/dnsmasq.hosts", '/dnsmasq.hosts'
      config.vm.synced_folder "#{Dir.pwd}/resolv.conf", '/resolv.conf'
      #d.synced_folder "#{Dir.pwd}/dnsmasq.hosts", '/dnsmasq.hosts'
      d.has_ssh = true
      d.name = 'net_server'
    end 
  end if systemsToBoot.index(:net_server)


  # Knoten server der alten All-In-One Server abbildet
  config.vm.define 'server' do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "server.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'server'
    end 
  end if systemsToBoot.index(:server)

  # Create a node able to run as a jenkins-CI server for Elexis (including Jubula GUI-tests)
  config.vm.define 'jenkins' do |node|
    node.vm.network "public_network" # via dhcp
    node.vm.provider "docker" do |d|
      d.build_dir = 'docker-elexis'
      d.create_args  = ["--hostname", "jenkins.ngiger.dyndns.org"] # works!
      d.cmd   = [ "/sbin/my_init", "--enable-insecure-key"]
      d.has_ssh = true
      d.name = 'jenkins'
    end 
  end if systemsToBoot.index(:jenkins)
end

