
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::common inherits elexis {
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
  
  $users_elexis_main        = hiera('users_elexis_main')
  $username = $users_elexis_main['name']
  Elexis::User[$username] -> Elexis::Users       <| |> 

  elexis::user{$username: 
    username   => $username,
    password   => $users_elexis_main['password'],
    uid        => $users_elexis_main['uid'],
    groups     => $users_elexis_main['groups'],
    comment    => $users_elexis_main['comment'],
    shell      => $users_elexis_main['shell'],
    ensure     => $users_elexis_main['ensure'],
    require    => Group[$groups_elexis_main],
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

  file { "$elexis::params::create_service_script":
    source => "puppet:///modules/elexis/create_service.rb",
    mode  => 0774,
    require =>         [
      File['/var/lib/service'],
      Package['daemontools-run'],
    ],
  }
  
}
