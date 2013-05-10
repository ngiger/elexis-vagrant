# -*- mode: ruby -*-
# vi: set ft=ruby :

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
# systemsToBoot = [ :server, :backup, :devel, :arzt ]
systemsToBoot = [ :server ]

# Patch the next lines if you have more than one elexis-vagrant running in your network
firstPort       = 10000   
macFirst2Bytes  = '0000'  

#------------------------------------------------------------------------------------------------------------
# End of simple customization
#------------------------------------------------------------------------------------------------------------
# All Vagrant configuration is done here. The most common configuration
# options are documented and commented below. For a complete reference,
# please see the online documentation at vagrantup.com.

# A good solution would be http://serverfault.com/questions/418422/public-static-ip-for-vagrant-boxes

Vagrant.configure("2") do |config|
  config.vm.box_url = boxUrl
  config.vm.network :public_network
end

Vagrant::Config.run do |config|
  puts "Using boxUrl #{boxUrl}"

  config.vm.boot_mode = :gui # :gui or :headless (default)
  config.vm.provision :puppet, :options => "--debug"
  config.vm.share_folder "hieradata", "/etc/puppet/hieradata", File.join(Dir.pwd, 'hieradata')
  config.vm.customize  ["modifyvm", :id, "--memory", 1024, "--cpus", 2,  ]

  config.vm.provision :shell, :path => "shell/main.sh"
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
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
  
end
