# Basic Puppet Apache manifest

class apache {
  exec { 'apt-get update':
    command => '/usr/bin/apt-get update'
  }

  package { "apache2":
    ensure => present,
  }

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
  }

  file { "/var/www/index.html":
  owner => 'root',
  ensure => present,
  require => Service['apache2'],
  content => '<h1>Hello</h1>from the vagrant VM running a MySQL-server for Elexis (ng)'
  }
}
