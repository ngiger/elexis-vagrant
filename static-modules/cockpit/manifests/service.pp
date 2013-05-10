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
class cockpit::service(
  $ensure  = true,

) inherits cockpit
{
  $cockpit_runner = "${cockpit::local_bin}/start_elexis_cockpit.sh"
  $cockpit_name     = "elexis_cockpit"
  $cockpit_run      = "/var/lib/service/$cockpit_name/run"
  
  if ("$ensure" == absent) {
    file{  ["$cockpit_runner"]:   ensure => absent, }
    $service_status = stopped
  } else {
    $service_status   = running
    file{"$cockpit_runner":
      content => "#!/bin/bash
cd  $vcsRoot
bundle install
ruby elexis-cockpit.rb >> elexis-cockpit.log 2>&1
",
      owner => 'elexis',
      group => 'elexis',
      require => [User['elexis'], File["$local_bin"]],
      mode    => 0755,  
    }
  }
  exec{ "$cockpit_run":
    command => "$elexis::params::create_service_script elexis $cockpit_name $cockpit_runner",
    path => "/usr/local/bin:/usr/bin:/bin",
    require => [
      File["$elexis::params::create_service_script", "$cockpit_runner"],
      User["elexis"],
    ],
    creates => "$cockpit_run",
    user => 'root',
  }        
  
  service{"$cockpit_name":
    ensure => $service_status,
    provider => "daemontools",
    path    => "$service_path",
    hasrestart => true,
    subscribe  => Exec["$cockpit_run"],
    require    => Exec["$cockpit_run"], 
  }
  
}
