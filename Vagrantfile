# -*- mode: ruby -*-
# vi: set ft=ruby :
# A good solution would be http://serverfault.com/questions/418422/public-static-ip-for-vagrant-boxes

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  private = '/opt/fileserver/elexis/boxes/Elexis-Wheezy-amd64.box'
  private = '/opt/src/veewee/Elexis-Wheezy-amd64.box'
  boxUrl = File.exists?(private) ? private : 'http://ngiger.dyndns.org/downloads/Elexis-Wheezy-amd64.box'
  puts "Using boxUrl #{boxUrl}"

  config.vm.boot_mode = :gui # :gui or :headless (default)
  
  # Every Vagrant virtual environment requires a box to build off of.
#  config.vm.provider :virtualbox do |vb|
#    vb.customize ["modifyvm", :id, "--memory", "2148", '--cpus', 2]
#  end
  config.vm.provision :puppet, :options => "--debug"
  config.vm.share_folder "hieradata", "/etc/puppet/hieradata", File.join(Dir.pwd, 'hieradata')

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
    server.vm.forward_port 3306, 13306    # MySQL
    server.vm.forward_port 4567, 14567    # Gollum (elexis-admin Wiki)
    server.vm.forward_port 8080, 18080    # Jenkins
    server.vm.forward_port 9393, 19393    # elexis-cockpit
  end
  
  config.vm.define :backup do |backup|  
    backup.vm.host_name = "backup.#{`hostname -d`.chomp}"
    backup.vm.network :hostonly, "192.168.50.20"
    backup.vm.box     = "Elexis-Wheezy-amd64"
    backup.vm.box_url = boxUrl
    backup.vm.forward_port   22, 20022    # ssh
    backup.vm.forward_port   80, 20080    # Apache
    backup.vm.forward_port 3306, 23306    # MySQL
    backup.vm.forward_port 4567, 24567    # Gollum (elexis-admin Wiki)
    backup.vm.forward_port 9393, 29393    # elexis-cockpit
  end
  
end
