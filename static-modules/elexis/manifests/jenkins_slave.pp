# Setup a jenkins-slave to be able to run Jubula tests on the local machine
# We use a password-less ssh login
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::jenkins_slave  inherits elexis::common {
  include jenkins
  require elexis::common
  
  $j_user = 'jenkins'
  $j_home = '/var/lib/jenkins'  # Home of jenkins user
  $s_user = 'jenkins-slave' 
  $s_home = "/opt/$s_user"                # Home of jenkins-slave user

  # notify { "Adding jenkins_slave: user $s_user living at $s_home and $j_user / $j_home": }
  user {"${s_user}":
    ensure => present,
    groups => ['adm','dialout', 'cdrom', 'plugdev', 'netdev',],
    home => "${s_home}",
    shell => '/bin/bash',
    managehome => true,
    password => '$6$G/6CqNvg$sOh9py6cPn3511GOiou3Oy6M7MtEaLejQESA5z9EeKoR0PCtpJ6EPb5XaxIlpgEGI.B.El9f9iYD9iQft7z8k0', # elexisTest
    password_max_age => '99999',
    password_min_age => '0',
  }

  File {
    owner => $s_user,
    require => [ User[$s_user], File[$s_home]],
  }

  # Use existing key files. This allows the user jenkins to login without a password into jenkins-slave
  file { ["${s_home}/.ssh"]:
    ensure => directory,
    require => [ File[["${s_home}"]]],
  }
  file { ["${s_home}"]:
    ensure => directory,
    require => [ User[$s_user]],
  }

  file {["${s_home}/.ssh/authorized_keys"]:
    ensure => present,
    owner  => $s_user,
    source => 'puppet:///modules/elexis/jenkins/id_rsa.pub',
    require =>[ User[$s_user], File["${s_home}/.ssh"]],
    notify => Service['jenkins'],
  }
  file { "${s_home}/xstartup":
    ensure => present,
    source => 'puppet:///modules/elexis/jubula/xstartup', # Copy from jubula-elexis project
  }

  $passwdScript = "${s_home}/set_vncpasswd.exp"
  file { $passwdScript:
    ensure => present,
    source => 'puppet:///modules/elexis/jubula/set_vncpasswd.exp',
    mode => 0755,
  }
  
  file { ["$j_home/.ssh"]:
    ensure => directory,
    owner   => $j_user,
  }
  
  file { "${j_home}/.ssh/id_rsa.pub":
    ensure => present,
    source => 'puppet:///modules/elexis/jenkins/id_rsa.pub',
    require => [ File["${j_home}/.ssh"]],
#    notify => Service['jenkins'],
  }

  file {["${j_home}/.ssh/id_rsa"]:
    ensure => present,
    owner  => $j_user,
    source => 'puppet:///modules/elexis/jenkins/id_rsa',
    require => File["${j_home}/.ssh"],
#    notify => Service['jenkins'],
  }

  if !defined(Package['expect']) { package{ 'expect': ensure => present, } }
  exec { $passwdScript:
    require => [User[$s_user], File[$passwdScript],  Package['vnc4server','expect']],
    command => "sudo -Hu $s_user $passwdScript",
    creates => "${s_home}/.vnc/passwd",
    path    => '/usr/bin:/bin',
  }

  # we need
  # * an X-Server (vnc4server)
  # * some method to create a snapshot (imagemagick)
  # * a X-Window manager (fvwm)
  package { ['imagemagick', 'fvwm', 'vnc4server']: ensure => installed, }

}
