#!/usr/bin/env ruby
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
# systemsToBoot = [ :vm_server, :backup, :devel, :arzt, :jenkins ]
systemsToBoot = [:server, :vm_server, :ubuntu]

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
#  config.vm.box_url = boxUrl
  config.vm.network :public_network
end

Vagrant::Config.run do |config|
  puts "Using boxUrl #{boxUrl}"

  config.vm.boot_mode = :gui # :gui or :headless (default)
  # config.vm.provision :puppet # , :options => "--verbose"
  config.vm.share_folder "hieradata", "/etc/puppet/hieradata", File.join(Dir.pwd, 'hieradata')
  config.vm.customize  ["modifyvm", :id, "--memory", 1024, "--cpus", 2,  ]

  config.vm.provision :shell, :path => "shell/install_puppet.sh"
#    ubuntu.vm.provision :shell, :path => "shell/install_puppet.sh" # as we get only a puppet 3.4 which has problems with UTF-8
  config.vm.provision :puppet do |puppet|
    puppet.options = ['--environment', 'development'] # , '--debug']
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/vagrant"
  end
  config.vm.define :server do |server|  
    server.vm.host_name = "server.#{`hostname -d`.chomp}"
    server.vm.network :bridged, { :mac => macFirst2Bytes + '27226F02', :bridge => bridgedNetworkAdapter }
#    server.vm.network :hostonly, "192.168.50.10"
    server.vm.box     = boxId
    server.vm.box_url = boxUrl
    server.vm.forward_port   22, firstPort +  22    # ssh
    server.vm.forward_port   80, firstPort +  80    # Apache
    server.vm.forward_port 3306, firstPort + 306    # MySQL
    server.vm.forward_port 4567, firstPort + 567    # Gollum (elexis-admin Wiki)
    server.vm.forward_port 9393, firstPort + 393    # elexis-cockpit
  end if systemsToBoot.index(:server)
  
  config.vm.define :backup do |backup|  
    backup.vm.host_name = "backup.#{`hostname -d`.chomp}"
    backup.vm.network :bridged, { :mac => macFirst2Bytes + '37226F02', :bridge => bridgedNetworkAdapter }
    backup.vm.box     = boxId
    backup.vm.box_url = boxUrl
    backup.vm.forward_port   22, firstPort + 1022    # ssh
    backup.vm.forward_port   80, firstPort + 1080    # Apache
    backup.vm.forward_port 3306, firstPort + 1306    # MySQL
    backup.vm.forward_port 4567, firstPort + 1567    # Gollum (elexis-admin Wiki)
    backup.vm.forward_port 9393, firstPort + 1393    # elexis-cockpit
  end if systemsToBoot.index(:backup)
  
  config.vm.define :devel do |devel|  
    config.vm.customize  ["modifyvm", :id, "--memory", 2048, "--cpus", 2,  ]
    devel.vm.host_name = "devel.#{`hostname -d`.chomp}"
    devel.vm.network :bridged, { :mac => macFirst2Bytes + '47226F02', :bridge => bridgedNetworkAdapter }
    devel.vm.box     = boxId
    devel.vm.box_url = boxUrl
    devel.vm.forward_port    22, firstPort + 2022    # ssh
    devel.vm.forward_port    80, firstPort + 2080    # Apache
    devel.vm.forward_port  8080, firstPort + 2888    # Jenkins
  end if systemsToBoot.index(:devel)
  
  config.vm.define :arzt do |arzt|  
    arzt.vm.host_name = "arzt.#{`hostname -d`.chomp}"
    arzt.vm.network :bridged, { :mac => macFirst2Bytes + '57226F02', :bridge => bridgedNetworkAdapter }
    arzt.vm.box     = "Elexis-Wheezy-amd64"
    arzt.vm.box_url = boxUrl
    arzt.vm.forward_port   22, firstPort + 3022    # ssh
  end if systemsToBoot.index(:arzt)
  
  config.vm.define :jenkins do |jenkins|  
    jenkins.vm.host_name = "jenkins.#{`hostname -d`.chomp}"
    jenkins.vm.network :bridged, { :mac => macFirst2Bytes + '67227F02', :bridge => bridgedNetworkAdapter }
    jenkins.vm.box     = boxId
    jenkins.vm.box_url = boxUrl
    jenkins.vm.forward_port    22, firstPort + 7022    # ssh
    jenkins.vm.forward_port    80, firstPort + 7080    # Apache
    jenkins.vm.forward_port  8080, firstPort + 7888    # Jenkins
  end if systemsToBoot.index(:jenkins)
  
  config.vm.define :ubuntu do |ubuntu|
    ubuntu.vm.host_name = "ubuntu.#{`hostname -d`.chomp}"
    ubuntu.vm.network :bridged, { :mac => macFirst2Bytes + '27228F02', :bridge => bridgedNetworkAdapter }
    
    ubuntu.vm.box = 'ubuntu-14.04-desktop-i386'
    ubuntu.vm.box_url = 'http://ngiger.dyndns.org/downloads/ubuntu-14.04-desktop-i386.box'
#    ubuntu.vm.box = 'ubuntu/trusty32'
#    ubuntu.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box'
#    ubuntu.vm.box = "precise-ubuntu-cloudimg-i386-vagrant-disk1"
#    ubuntu.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-ubuntu-cloudimg-i386-vagrant-disk1.box'
    ubuntu.vm.forward_port    22, firstPort + 8022    # ssh
    ubuntu.vm.forward_port    80, firstPort + 8080    # Apache
    ubuntu.vm.forward_port  8080, firstPort + 8888    # Jenkins
  end if systemsToBoot.index(:ubuntu)

  
end
