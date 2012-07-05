# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

# stages are use like this:
# first: Install additional apt-sources, keys etc
# second: Call apt-get update
# main:  Install packages, gems, configure files, etc
# last:  Start services (e.g. apache, gollum, jenkins, x2go)
notify { "site.pp for vagrant/elexis": }

stage { 'first': before => Stage['second'] }
stage { 'second': before => Stage['main'] }
stage { 'last': require => Stage['main'] }
class { 'apt': proxy_host => "172.25.1.61",
  proxy_port => 3142,
  # purge_sources_list => true,
  purge_sources_list_d => true }
# class { 'apt::release':  release_id => "precise"  }

class apt_get_update {
    exec{'apt_get_update':
      command => "apt-get update",
      path    => "/usr/bin:/usr/sbin:/bin:/sbin",
      refreshonly => true,
    }
}
class {
      'apt_get_update': stage => second;
      'apache':   stage => last;
    }

include apt_get_update

notify { "ruby version is $rubyversion": }
case $rubyversion {
  '1.8.7' : { package { 'rubygems':
      ensure => present,
    }
  }
  default : { notify { "Noting to do for $rubyversion": }
  }
}

# TODO: etckeeper under ubuntu needs bzr installed or a changed /etc/etckeeper/etckeeper.conf
# TODO: call etckeeper init if !File.exists?('/etc/.bzr')
# see https://github.com/fundecho/puppet-etckeeper
# Probably better https://github.com/thomasvandoren/puppet-etckeeper

package{  ['vim', 'vim-nox', 'vim-puppet', 'git', 'etckeeper', 'puppet', 'dlocate', 'mlocate', 'htop', 'curl', 'bzr']:
  ensure => present,
}

$vcsRoot = '/home/vagrant'
  file { $vcsRoot:
    ensure => directory,
  }

vcsrepo { "$vcsRoot/elexis-vagrant":
    ensure => present,
    provider => git,
    require => File[$vcsRoot],
    owner => 'vagrant',
    source => "git://github.com/ngiger/elexis-vagrant.git"
}

import "nodes/*.pp"

node default {
    notify { "site.pp node default": }
}
