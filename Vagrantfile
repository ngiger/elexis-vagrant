# see http://vagrantup.com
# Copyright (c) Niklaus Giger, <niklaus.giger@member.fsf.org>
# License: GPLv2
# Boxes are stored under ~/.vagrant.d/boxes/
Vagrant::Config.run do |config|
  # Setup the box
#  config.vm.box     = "elexis.server"
#  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
#  config.vm.host_name = "elexis.server"
#  config.vm.network :bridged { :adapter => "eth0", :bridge => "elexis-network", :mac => "02:04:06:08:0a:0c"}
  config.vm.network :bridged
  config.vm.define :elexisServer do |server|
    server.vm.box     = "elexisServer"
    server.vm.host_name = "elexisServer"
    server.vm.box_url = "http://files.vagrantup.com/precise64.box"
    server.vm.forward_port 80, 8880
    server.vm.forward_port 3306, 33306
    server.vm.network :bridged
    # Enable the Puppet provisioner
    server.vm.provision :puppet
#    server.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)

#    server.ssh.port   = 2223
  end

  config.vm.define :elexisClient do |client|
    client.vm.box     = "elexisClient"
    client.vm.host_name = "elexisClient"
    client.vm.box_url = "http://files.vagrantup.com/precise64.box"
    client.vm.box = "db"
    client.vm.network :bridged
    client.ssh.port   = 2224
  end
end
