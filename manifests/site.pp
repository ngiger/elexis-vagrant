# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
package{  ['vim', 'vim-nox', 'vim-puppet', 'git', 'etckeeper', 'puppet', 'dlocate', 'mlocate', 'htop']:
  ensure => present,
}


# include x2go::common

file {'/etc/apt/apt.conf.d/41_proxy':
  ensure => present,
  owner   => root,
#  content => "Acquire::http::Proxy \"$APTPROXY\";\n",
  content => "Acquire::http::Proxy \"http://172.25.1.61:3142\";\n",
#  notify => Exec['x2go_apt_update'],
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
#    include x2go
}
