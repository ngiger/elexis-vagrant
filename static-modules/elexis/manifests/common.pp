# Here we define quite a few parameters
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::common (
  $downloadDir = "/opt/downloads",
  $destZip = "${downloadDir}/floatflt.zip",
  $elexisFileServer = "http://ftp.medelexis.ch/downloads_opensource",
)  inherits elexis {
#  notify { "downloadURL     is set to '$downloadURL'": }
#  notify { "dbMain          is set to '$db_main'": }
  
  file { $downloadDir:
    ensure => directory, # so make this a directory
  }

  include apt # to force an apt::update
  group { 'elexis':
    ensure => present,
    gid => 1300,
  }

  group {[ 'adm','dialout', 'cdrom', 'plugdev', 'netdev']:
    ensure => present,
  }

  user { 'elexis':
    ensure => present,
    uid => 1300,
    gid => 'elexis',
    groups => ['adm','dialout', 'cdrom', 'plugdev', 'netdev'],
    home => '/home/elexis',
    managehome => true,
    shell => '/bin/bash',
    password => 'elexisTest',
#    password => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/', # elexisTest
    password_max_age => '99999',
    password_min_age => '0',
  }
  
  package{['daemontools-run', 'anacron']:} 
  file {'/var/lib/service':
    ensure => directory,
    mode  => 0644,
  }
  
  file {'/etc/sudoers.d/elexis':
    ensure => present,
    content => "elexis ALL=NOPASSWD:ALL\n",
    mode  => 0644,
  }

  file { "$create_service_script":
    source => "puppet:///modules/elexis/create_service.rb",
    mode  => 0774,
    require =>         [
      File['/var/lib/service'],
      Package['daemontools-run'],
    ],
  }
  
}
