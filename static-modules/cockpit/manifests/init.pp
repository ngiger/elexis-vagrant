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
  $local_bin = '/usr/local/bin',
) inherits elexis {
  include elexis::params  
  include elexis::common
  # ensure_resource('user', 'elexis', {ensure => present,} )
  ensure_resource('file', $local_bin, {ensure => directory,} )
  ensure_packages(['bash', 'curl', 'git', 'patch', 'bzip2', 'build-essential', 
    'openssl', 'libreadline6', 'libreadline6-dev', 'curl', 'zlib1g', 
    'zlib1g-dev', 'libssl-dev', 'libyaml-dev', 'libsqlite3-dev', 'sqlite3', 'libxml2-dev', 
    'libxslt-dev', 'autoconf', 'libc6-dev', 'libgdbm-dev', 'ncurses-dev', 'automake', 
    'libtool', 'bison', 'libffi-dev', 'libvirt-dev', 'ruby1.9.1', 
    'libaugeas-ruby'
  ])   

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
      path => "$local_bin:/usr/bin:/bin",
      user => 'elexis',
      require => [ Vcsrepo[$vcsRoot], 
        Package['bundle'],
#        File["$local_bin"],
        ],
    }
    exec { 'gen_mockconfig':
      command => "rake mock_scripts 2>&1| tee $vcsRoot/mock_scripts.log",
      creates => "$vcsRoot/mock_scripts.log",
      cwd => "/usr/bin",
      path => "$local_bin:/usr/bin:/bin",
      require =>  [ Vcsrepo[$vcsRoot], 
                    File["$local_bin"],
                    Exec['bundle_trust_cockpit'], ],
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
  else { 
    $pkg_ensure = absent 
  }	

}
