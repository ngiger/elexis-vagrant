# see http://vagrantup.com
# Copyright (c) Niklaus Giger, <niklaus.giger@member.fsf.org>
# License: GPLv2
# Boxes are stored under ~/.vagrant.d/boxes/

Vagrant::Config.run do |config|
  # Setup the box
#  config.vm.network :bridged

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "default.pp"
    puppet.module_path = "modules"
    puppet.options = '--verbose --debug'
  end

  config.vm.provision :puppet_server do |puppet|
    # First step: simple one. Use the files here, see http://vagrantup.com/v1/docs/provisioners/puppet.html    
#    puppet.manifests_path = "manifests"
#    puppet.manifest_file = "default.pp"
#    puppet.module_path = "modules"
    # Second step: if you are using a real puppet server
    # puppet.puppet_server = '192.168.1.111'
    # puppet.options = '--verbose --debug --genconfig'
  end
  config.vm.define :elexisServer do |server|
    server.vm.network :hostonly, "192.168.2.114"
#    server.vm.network :bridged
    server.vm.box     = "elexisServer"
    server.vm.host_name = "elexisServer"
    server.vm.box_url = "http://files.vagrantup.com/precise64.box"
    server.vm.forward_port 80, 8880
    server.vm.forward_port 3306, 33306
    # Enable the Puppet provisioner
#    server.vm.provision :puppet
#    server.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)

#    server.ssh.port   = 2223
  end

  config.vm.define :elexisClient do |client|
    client.vm.network :bridged
    client.vm.box     = "elexisClient"
    client.vm.host_name = "elexisClient"
    client.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end if false
end
