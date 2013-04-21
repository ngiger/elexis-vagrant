# -*- mode: ruby -*-
# vi: set ft=ruby :
# All Vagrant configuration is done here. The most common configuration
# options are documented and commented below. For a complete reference,
# please see the online documentation at vagrantup.com.

# A good solution would be http://serverfault.com/questions/418422/public-static-ip-for-vagrant-boxes
private = '/opt/src/veewee-ngiger/Elexis-Wheezy-amd64.box'
boxUrl = File.exists?(private) ? private : 'http://ngiger.dyndns.org/downloads/Elexis-Wheezy-amd64.box'
puts "Using boxUrl #{boxUrl}"

Vagrant.configure("2") do |config|
  config.vm.box_url = boxUrl
  config.vm.network :public_network
end

Vagrant::Config.run do |config|
  private = '/opt/fileserver/elexis/boxes/Elexis-Wheezy-amd64.box'
  private = '/opt/src/veewee/Elexis-Wheezy-amd64.box'
  boxUrl = File.exists?(private) ? private : 'http://ngiger.dyndns.org/downloads/Elexis-Wheezy-amd64.box'
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
    server.vm.network :hostonly, "192.168.50.10"
    server.vm.box     = "Elexis-Wheezy-amd64"
    server.vm.box_url = boxUrl
    server.vm.forward_port   22, 10022    # ssh
    server.vm.forward_port   80, 10080    # Apache
    server.vm.forward_port 3306, 10306    # MySQL
    server.vm.forward_port 4567, 10567    # Gollum (elexis-admin Wiki)
    server.vm.forward_port 9393, 10393    # elexis-cockpit
  end
  
  config.vm.define :backup do |backup|  
    backup.vm.host_name = "backup.#{`hostname -d`.chomp}"
    backup.vm.network :bridged, { :mac => '000037226F02' }
    backup.vm.box     = "Elexis-Wheezy-amd64"
    backup.vm.box_url = boxUrl
    backup.vm.forward_port   22, 23022    # ssh
    backup.vm.forward_port   80, 23080    # Apache
    backup.vm.forward_port 3306, 23306    # MySQL
    backup.vm.forward_port 4567, 23567    # Gollum (elexis-admin Wiki)
    backup.vm.forward_port 9393, 23393    # elexis-cockpit
  end
  
  config.vm.define :devel do |devel|  
    config.vm.customize  ["modifyvm", :id, "--memory", 2048, "--cpus", 2,  ]
    devel.vm.host_name = "devel.#{`hostname -d`.chomp}"
    devel.vm.network :bridged, { :mac => '000047226F02' }
    devel.vm.box     = "Elexis-Wheezy-amd64"
    devel.vm.box_url = boxUrl
    devel.vm.forward_port    22, 24022    # ssh
    devel.vm.forward_port    80, 24080    # Apache
    devel.vm.forward_port  8080, 24888    # Jenkins
  end
  
  config.vm.define :arzt do |arzt|  
    arzt.vm.host_name = "arzt.#{`hostname -d`.chomp}"
    arzt.vm.network :bridged, { :mac => '000057226F02' }
    arzt.vm.box     = "Elexis-Wheezy-amd64"
    arzt.vm.box_url = boxUrl
    arzt.vm.forward_port   22, 25022    # ssh
  end
  
end
