# Things to setup to be able to run Jubula tests for Elexis

class elexis::jubula  inherits elexis::common {
  include jubula # add the Jubula

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
    managehome => true,
    password => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/', # elexisTest
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

  exec { $passwdScript:
    require => [User[$slaveUser], File[$passwdScript],  Package['vnc4server']],
    command => "sudo -u $slaveUser $passwdScript",
    creates => "$slaveHome/.vnc/passwd",
    path    => '/usr/bin:/bin',
  }
  package { ['imagemagick', 'fvwm', 'vnc4server']: ensure => installed, }
  
  # imagemagick is needed to take snapshots
  # fvwm, vnc4server is needed for running headless under Jenkins
  # I think we will need some configuration too
  # I used the xstartup from the jubula-elexis-project.
  # TODO: configure jenkins node correctly /computer/ng-hp/configure
#  package { ['imagemagick', 'fvwm', 'vnc4server']:
  # jubula needs a 32-bit Java
  case $architecture {
      /amd64/:  {
	package { ['ia32-libs']: ensure => present, }
	case $operatingsystem {
	      'Debian':  { } 
	      'Ubuntu': {
		package { ['openjdk-6-jre-headless:i386']:
		  ensure => present,
		}
	      }
	      default: { notify { "\n Jubula-Setup: Don't know to handle ${operatingsystem}": } }
	}
      }
      default: { notify { "Jubula-setup: No 32-bit Java needed for ${architecture}": } }
  }

}
# vi: set ft=ruby :