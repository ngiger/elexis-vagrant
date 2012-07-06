# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

# stages are use like this:
# first: Install additional apt-sources, keys etc
# second: Call apt-get update
# main:  Install packages, gems, configure files, etc
# last:  Start services (e.g. apache, gollum, jenkins, x2go)
notify { "site.pp for vagrant/elexis": }

class { 'apt': proxy_host => "172.25.1.61",
  proxy_port => 3142,
  # purge_sources_list => true,
#  purge_sources_list_d => true  
}
# class { 'apt::release':  release_id => "precise"  }
# include apt
# include apt::release

if ($operatingsystem == 'Debian'  and '6.1' == $operatingsystemrelease ) {
  notify {"need newer puppet for Debian/Squeeze $operatingsystemrelease":}
  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main',
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
    release    => 'squeeze',
  }
}

# package { 'puppet':
#   ensure => latest,
#  release => 'squeeze',
# }

stage { 'first': before => Stage['second'] }
stage { 'second': before => Stage['main'] }
stage { 'last': require => Stage['main'] }

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

case $rubyversion {
  '1.8.7' : {
    notify { "ruby version $rubyversion needs rubygems": }
    package { 'rubygems':
      ensure => present,
    }
  }
  default : { }
}

include etckeeper # will define package git, too
package{  ['vim', 'vim-nox', 'vim-puppet', 'dlocate', 'mlocate', 'htop', 'curl', 'bzr', 'unzip']:
  ensure => present,
}

import "nodes/*.pp"

node default {
    notify { "site.pp node default": }
}
