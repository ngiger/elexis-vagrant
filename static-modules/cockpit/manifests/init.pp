# == Class: cockpit
#
# This class installs the Elexis-Cockpit project.
# By default it generates mock scripts and instals the Sinatra
# application listening on port 9393
#
# === Parameters
#
# none
#
# === Variables
# useMock = default true. generates mockscripts. This is safe
#         as we the app will usually to heavy stuff like rebooting the 
#         server
# ensure  = present or absent. If absent will purge the repository, too
# vcsRoot = where to install the checkout copy of the elexis-cockpit app
# initFile = the init script
# rubyVersion = The ruby version to install. Must match the Gemfile 
#
# === Examples
#
#  class { "cockpit::service": initFile = '/my/Personal/Path', }
#  class { "cockpit::service":  }
#
# === Authors
#
# Niklaus Giger <niklaus.giger@member.fsf.org>
#
# === Copyright
#
# Copyright 2013 Niklaus Giger <niklaus.giger@member.fsf.org>
#
class cockpit(
  $useMock = hiera('elexis::cockit::useMock', false),
  $ensure  = hiera('elexis::cockit::ensure ', true),
  $vcsRoot = hiera('elexis::cockit::vcsRoot', '/home/elexis/cockpit'),
) inherits elexis {
  include elexis::params
  
  # TODO: Install correct ruby 
  if ($ensure != absent ) { 
    $pkg_ensure = present 
 
    package{ 'bundle':
      provider => gem,
      ensure => installed,
    }
    exec { 'bundle_trust_cockpit':
      command => "bundle install --gemfile $vcsRoot/Gemfile.1.9.3 &> $vcsRoot/install.log",
      creates => "$vcsRoot/install.log",
      cwd => "/usr/bin",
      path => '/usr/local/bin:/usr/bin:/bin',
      user => 'elexis',
      require => [ Vcsrepo[$vcsRoot], 
        Package['bundle'] 
        ],
    }
    exec { 'gen_mockconfig':
      command => "rake mock_scripts 2>&1| tee mock_scripts.log",
      creates => "$vcsRoot/mock_scripts.log",
      cwd => "/usr/bin",
      path => '/usr/local/bin:/usr/bin:/bin',
      require =>  [ Vcsrepo[$vcsRoot], 
                    Exec['bundle_trust_cockpit'], ],
    }
  } 
  else { 
    $pkg_ensure = absent 
    notify{"ohne $initFile da $ensure und pkg $pkg_ensure ":} 
  }	

  vcsrepo {  "$vcsRoot":
      ensure => $pkg_ensure,
      provider => git,
      owner => 'elexis',
      group => 'elexis',
      source => "https://github.com/elexis/elexis-cockpit.git",
      require => [User['elexis'],],
  }  
}


class cockpit::service(
  $ensure  = true,

) inherits cockpit
{
  include elexis::common
  
  $cockpit_name     = "elexis_cockpit"
  $cockpit_run      = "/var/lib/service/$cockpit_name/run"
  exec{ "$cockpit_run":
    command => "$elexis::params::create_service_script elexis $cockpit_name 'ruby $vcsRoot/elexis-cockpit.rb'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$elexis::params::create_service_script"],
      User["elexis"],
    ],
    creates => "$cockpit_run",
    user => 'root',
  }

  file{'/etc/init.d/cockpit': ensure => absent }
  
  service{"$cockpit_name":
    ensure => running,
    provider => "daemontools",
    path    => "$service_path",
    hasrestart => true,
    subscribe  => Exec["$cockpit_run"],
    require    => Exec["$cockpit_run"], 
  }
  
}
