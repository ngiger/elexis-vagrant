class { 'elexis':
  java               => 'openjdk-7-jdk'
}
# we need also an x-display-manager, e.g. slim
# an x-window-manager, e.g. awesome
# demoDB is not getting installed!

package {['slim', 'awesome']: }

if (0==1) {
  include elexis::install
  elexis::install {"elexis-Medelexis":
    programURL             => 'http://www.medelexis.ch/dl21.php?file=medelexis-linux',
    version                => 'current',
    installBase            => '/opt/elexis',
  }

} else {
  # Generates Error: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type elexis::install at /tmp/vagrant-puppet/modules-0/elexis/tests/install.pp:5 on node server.ngiger.dyndns.org
  elexis::install  {"elexis-2.1.7.rc-opensource":
    programURL             => 'http://ftp.medelexis.ch/downloads_opensource/elexis/2.1.7.rc2/elexis-2.1.7.20121007-installer.jar',
    version                => '2.1.7.rc2',
    installBase            => '/opt/elexis_opensource',
  }

}

