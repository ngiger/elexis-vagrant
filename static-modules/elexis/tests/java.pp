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

class java($version) {
  package { "python-software-properties": }

  exec { "add-apt-repository-oracle":
    command => "/usr/bin/add-apt-repository -y ppa:webupd8team/java",
    notify => Exec["apt_update"]
  }

  exec {
    'set-licence-selected':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';

    'set-licence-seen':
      command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
  }

  package { 'oracle-java7-installer':
    ensure => "${version}",
    require => [Exec['add-apt-repository-oracle'], Exec['set-licence-selected'], Exec['set-licence-seen']],
  }
}