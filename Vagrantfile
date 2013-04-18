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

  # Every Vagrant virtual environment requires a box to build off of.
#  config.vm.provider :virtualbox do |vb|
#    vb.customize ["modifyvm", :id, "--memory", "2148", '--cpus', 2]
#  end
  config.vm.host_name = "server.#{`hostname -d`.chomp}"
  config.vm.network :hostonly, "192.168.50.10"
  # config.vm.network("192.168.2.10")
  config.vm.box = "Elexis-Wheezy-amd64"
  config.vm.provision :puppet, :options => "--debug"
  config.vm.share_folder( File.join(Dir.pwd, 'hieradata'), "/etc/puppet/hieradata", ".")

  config.vm.provision :shell, :path => "shell/main.sh"
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
  end

  config.vm.forward_port  22,  10022
  config.vm.forward_port  80,  10080
  config.vm.forward_port  3306,  13306
  config.vm.forward_port  4567,  14567
  config.vm.forward_port  8080,  18080
  config.vm.forward_port  9393,  19393

end
