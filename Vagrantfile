# see http://vagrantup.com
# Copyright (c) Niklaus Giger, <niklaus.giger@member.fsf.org>
# License: GPLv2
# Boxes are stored under ~/.vagrant.d/boxes/

Vagrant::Config.run do |config|
  # Setup the box
  config.vm.provision :puppet, :options => "--verbose --debug"
  # Ruby gem buildr needs a JAVA_HOME=/usr/lib/jvm/default-java/
  config.vm.provision :puppet, :facter => { "JAVA_HOME" => "/usr/lib/jvm/default-java/" }
  # correct the next line to add the hostname/ip-address where we can find an apt-cache
  # remove it or uncomment it, if you don't have an apt cache
  # /etc/puppet/puppet.conf
  config.vm.provision :puppet, :facter => { "APTPROXY" => "http://172.25.1.61:3142/" }
  config.vm.customize do |vm|
    vm.memory_size = 2048 # MB
  end
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
  end
  config.vm.define :elexisDev do |server|
    server.vm.network :hostonly, "10.11.12.13"
    server.vm.box     = "elexisDev"
    server.vm.host_name = "elexisDev"
    server.vm.box_url = "http://files.vagrantup.com/precise64.box"
#    server.vm.box_url = "http://ngiger.dyndns.org/elexisBaseBox.box"
    config.vm.boot_mode = :gui # :gui or :headless (default)
    server.vm.forward_port   80, 30080		# Apache
    server.vm.forward_port 3306, 33306		# MySQL
    server.vm.forward_port 4567, 34567		# Gollum (elexis-admin Wiki)
    server.vm.forward_port 8080, 38080		# Jenkins
  end
end
