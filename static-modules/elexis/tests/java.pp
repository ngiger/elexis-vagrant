# include java7

#file { 'jdk-7u51-linux-x64.tar.gz':
#  path => '/tmp/tst',
#  content => "Test ng",
#  }
#include sunjdk
# puppet://{server hostname (optional)}/{mount point}/{remainder of path}$
#  Could not retrieve information from environment production source(s) puppet:///files/jdk-7u51-linux-x64.tar.gz
# workaround is to download  to /opt/downloads and have a /etc/puppet/fileserver.conf
#[files]
#    path /opt/downloads
# wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz"


#java::setup { 'jdk_6u31':
#   ensure        => present,
#   source        => 'jdk-6u31-linux-x64.bin',
#   deploymentdir => '/opt/jdk',
#   user          => 'root',
# }

class java {
  package { "python-software-properties": }

        $installer =  'oracle-java7-installer'

  case $operatingsystem {
      'Debian':  {
      class { 'apt': always_apt_update    => true, }
  apt::source { 'webupd8team':
  location          => 'http://ppa.launchpad.net/webupd8team/java/ubuntu',
  release           => 'precise',
  repos             => 'main',
#  required_packages => 'debian-keyring debian-archive-keyring',
  key               => 'EEA14886',
#  key_server        => 'keyserver.ubuntu.com',
  pin               => '-10',
  include_src       => true
}
  $dependencies = [ Apt::Source['webupd8team'], Exec['apt_update']]
  }
      'Ubuntu': {
  include apt
  apt::ppa { "ppa:webupd8team/java": }
  $dependencies = Apt::Ppa['ppa:webupd8team/java']
      } # apply the redhat class
      default:  { fail("\nx2go not (yet?) supported under $operatingsystem!!")
  $dependencies = []
          file {"$x2go_dpkg_list":
            ensure => present,
            owner   => root,
            content => "deb http://packages.x2go.org/debian $dist main
deb src http://packages.x2go.org/debian $dist main
",
          }
        
      }
    }

  exec {
    'set-licence-selected':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';

    'set-licence-seen':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
  }

  package {$installer:
    ensure => "latest",
    require => [ $dependencies, Exec['set-licence-selected'], Exec['set-licence-seen']],
  }
}

include java