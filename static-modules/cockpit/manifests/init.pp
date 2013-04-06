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
  $useMock = true,
  $ensure  = true,
  $vcsRoot = '/home/elexis/cockpit',
  $initFile = '/etc/init.d/cockpit',
  $rubyVersion = 'ruby-2.0.0-p0',
) {


  include rvm
  if !defined(User['elexis']) {
    user { 'elexis': ensure => present }
  }
  if ($ensure != absent ) { 
    $pkg_ensure = present 
 
    # rvm does not handle absent correctly!
    rvm_system_ruby {
      "$rubyVersion":
        ensure => $pkg_ensure,
        default_use => false;
    }
     
    rvm_gemset {
      "$rubyVersion@cockpit":
        ensure => $pkg_ensure,
        require => Rvm_system_ruby[ $rubyVersion  ];
    }
    
    rvm_gem {
      "$rubyVersion@cockpit/bundler":
        ensure => $pkg_ensure,
        require => Rvm_gemset["$rubyVersion@cockpit"];
    }
      
    exec { 'bundle_trust_cockpit':
      command => "sudo -iH rvm $rubyVersion do bundle install --gemfile $vcsRoot/Gemfile &> $vcsRoot/install.log",
      creates => "$vcsRoot/install.log",
      cwd => "/usr/bin",
      path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
      require => [  Rvm_gem ["$rubyVersion@cockpit/bundler"],
                    Vcsrepo[$vcsRoot] ],
    }
    exec { 'gen_mockconfig':
      command => "rvm rvmrc trust $vcsRoot \
      && cd $vcsRoot && pwd   \
      && rake mock_scripts 2>&1| tee mock_scripts.log",
      creates => "$vcsRoot/mock_scripts.log",
      cwd => "/usr/bin",
      path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
      require =>  [ Rvm_system_ruby["$rubyVersion"], Vcsrepo[$vcsRoot], 
                    Exec['bundle_trust_cockpit'], ],
    }
  } 
  else { 
    $pkg_ensure = absent 
    notify{"ohne $initFile da $ensure und pkg $pkg_ensure ":} 
  }	
	
  file  { $initFile:
    content => template('cockpit/cockpit.init.erb'),
    ensure => $pkg_ensure,
    owner => 'root',
    group => 'root',
    mode  => 0754,
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
  if ($ensure != absent) {
    notify{"mit service da $ensure":} 
    service { 'cockpit':
      ensure => running,
      enable => true,
      hasstatus => false,
      hasrestart => false,
      require =>  [ File["$cockpit::initFile"], 
        Exec[ 'bundle_trust_cockpit', 'gen_mockconfig'] ],
    }
  } else {
    notify{"ohne service da $ensure":} 
    service { 'cockpit':
      ensure => stopped,
      enable => true,
      hasstatus => false,
      hasrestart => false,
    }
  } 
}
