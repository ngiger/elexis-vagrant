# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class elexis::cockpit inherits elexis::common {
  $initFile =  '/etc/init.d/cockpit'

  package{  ['sinatra',
    'shotgun', 
    'hiera',
    'sys-filesystem',
    'actionpack',
    ]:
    ensure => present,
    provider => gem,
#    require => Package['make', 'libxslt*-dev', 'libxml2-dev'],
  }

  file  { $initFile:
    source => 'puppet:///modules/elexis/cockpit.init',
    owner => 'root',
    group => 'root',
    mode  => 0754,
  }
}

class elexis::cockpit_service inherits elexis::cockpit {
  service { 'cockpit':
    ensure => running,
    enable => true,
    hasstatus => false,
    hasrestart => false,
  }
}

class {'elexis::cockpit_service':stage => last; }
