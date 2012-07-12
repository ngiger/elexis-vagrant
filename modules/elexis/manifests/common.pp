# Here we define a few packages which are common to all elexis instances
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
class elexis::common {
  $downloadDir = "/opt/downloads"
  $destZip = "${downloadDir}/floatflt.zip"
  $elexisFileServer = 'http://172.25.1.61/fileserver/elexis'
  case $elexisFileServer {
        /^http|^ftp/:  { $downloadURL = $elexisFileServer }
        default: { $downloadURL = 'http://ftp.medelexis.ch/downloads_opensource'}
    }
  notify { "downloadURL is set to '$downloadURL'": }
  file { $downloadDir:
    ensure => directory, # so make this a directory
  }
  
  include apt # to force an apt::update
  include java
  group { 'elexis':
    ensure => present,
    gid => 1300,
  }

  group {[ 'adm','dialout', 'cdrom', 'plugdev', 'netdev',]:
    ensure => present,
  }

  user { 'elexis':
    ensure => present,
    uid => 1300,
    gid => 'elexis',
    groups => ['adm','dialout', 'cdrom', 'plugdev', 'netdev',],
    home => '/home/elexis',
    managehome => true,
    shell => '/bin/bash',
#    password => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/', # elexisTest
    password_max_age => '99999',
    password_min_age => '0',
  }

  file {['/home/vagrant/.bash_aliases', '/root/.bash_aliases', '/home/elexis/.bash_aliases']:
    ensure => present,
    content => "alias ll='ls -la'\n",
    mode => 0444,
  }
}
