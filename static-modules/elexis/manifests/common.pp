
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::common(
  $backup_dir = '',
  $export_options = [rw, insecure, no_subtree_check, async, no_root_squash],
  $export_clients = '172.25.0.0/16',
)
inherits elexis {
  include elexis::params
  
  if !defined(User["jenkins"]) {
    user { 'jenkins': ensure => present}
  }
  if !defined(File["$jenkinsDownloads"]) {
    file { "$jenkinsDownloads":
      ensure => directory, # so make this a directory
      require => [ File[$jenkinsRoot], User['jenkins'], ],
    }    
  }
  
  if ( $backup_dir) {
    include nfs
    class { 'nfs::server':
        package => latest,
        service => running,
        enable  => true,
    }
    nfs::export {"$backup_dir":
        options =>  [ $export_options ],
        clients =>  [ $export_clients ],
    }

    nfs::export {"/home":
        options =>  [ $export_options ],
        clients =>  [ $export_clients ],
    }
  }

  file {"$jenkinsRoot":
    owner => 'jenkins',
    mode => '644',
    ensure => directory, # so make this a directory
    require => User['jenkins'],
  }

  file { "$elexis::downloadDir":
    ensure => directory, # so make this a directory
  }

  include apt # to force an apt::update
  $groups_elexis_main        = flatten([hiera('groups_elexis_main', [ 'dialout', 'cdrom', 'plugdev', 'netdev', 'adm', 'sudo', 'ssh' ]), 'mysql'] )
  # notify{ "elexis::common $groups_elexis_main": }
  group {$groups_elexis_main:  ensure => present,  }
  
  $users_elexis_main        = hiera('users_elexis_main', {})
  # notify{"users_elexis_main is $users_elexis_main":}
  $username = $users_elexis_main['name']
  if ($username) {
    Elexis::User[$username] -> Elexis::Users       <| |>

    elexis::user{$username: 
      username   => $username,
      password   => $users_elexis_main['password'],
      uid        => $users_elexis_main['uid'],
      groups     => $users_elexis_main['groups'],
      comment    => $users_elexis_main['comment'],
      shell      => $users_elexis_main['shell'],
      ensure     => $users_elexis_main['ensure'],
#      require    => Group[$groups_elexis_main],
    }
  } else {
    elexis::user{'elexis': 
      username   => 'elexis',
      password   => 'elexisTest',
      uid        => '1300',
      groups     => [],
      comment    => 'Default Elexis User',
      shell      => '/bin/bash',
      ensure     => present,
    }
  }

  if (false)  { # must be moved to a separate class to be included only when needed
    ensure_packages(['daemontools-run'])
    file {'/var/lib/service':
      ensure => directory,
      mode  => 0644,
    }
    
    file { "$elexis::params::create_service_script":
      source => "puppet:///modules/elexis/create_service.rb",
      mode  => 0774,
      require =>         [
        File['/var/lib/service'],
        Package['daemontools-run'],
      ],
    }
  }
  ensure_packages(['anacron'])
  file {'/etc/sudoers.d/elexis':
    ensure => present,
    content => "elexis ALL=NOPASSWD:ALL\n",
    mode  => 0440,
  }

  
}
