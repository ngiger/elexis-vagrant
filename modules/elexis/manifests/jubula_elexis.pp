# Things to setup to be able to run Jubula tests for Elexis
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::jubula_elexis  inherits elexis::common {

  class {"jubula":
    jubulaURL => 'http://ftp.medelexis.ch/downloads_opensource/jubula/jubula_setup_5.2.00266.sh',
    destDir =>  '/opt/jubula_5.2.00266',
    setupSh => '/opt/downloads/jubula_5.2.00266.sh'
  }
    
  include elexis::server # we need also the elexis-db

  mysql::db { 'jubula_vagrant':
    user     => 'elexis',
    password => 'elexisTest',
    host     => 'localhost',
    grant    => ['all'],
  }

  $slaveUser = 'jenkins-slave'
  $slaveHome = "/opt/$slaveUser"

  user {$slaveUser:
    ensure => present,
#    groups => ['adm','dialout', 'cdrom', 'plugdev', 'netdev',],
    home => $slaveHome,
    shell => '/bin/bash',
    managehome => true,
#    password => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/', # elexisTest
    password => '$6$G/6CqNvg$sOh9py6cPn3511GOiou3Oy6M7MtEaLejQESA5z9EeKoR0PCtpJ6EPb5XaxIlpgEGI.B.El9f9iYD9iQft7z8k0', # elexisTest
    password_max_age => '99999',
    password_min_age => '0',
  }

  File {
    owner => $slaveUser,
    require => User[$slaveUser],
  }
  
  file { "$slaveHome/xstartup":
    source => 'puppet:///modules/elexis/jubula/xstartup', # Copy from jubula-elexis project
  }

  $passwdScript = "$slaveHome/set_vncpasswd.exp"
  file { $passwdScript:
    source => 'puppet:///modules/elexis/jubula/set_vncpasswd.exp',
    mode => 0755,
  }

  file { "$slaveHome/vagrant_runs_jenkins.rb":
    source => 'puppet:///modules/elexis/jubula-elexis-2.1.7/run_jenkins.rb',
    mode => 0755,
  }

  if !defined(Package['expect']) { package{ 'expect': ensure => present, } }
  exec { $passwdScript:
    require => [User[$slaveUser], File[$passwdScript],  Package['vnc4server','expect']],
    command => "sudo -Hu $slaveUser $passwdScript",
    creates => "$slaveHome/.vnc/passwd",
    path    => '/usr/bin:/bin',
  }
  
  package { ['imagemagick', 'fvwm', 'vnc4server']: ensure => installed, }
  
}
# vi: set ft=ruby :