# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

# stages are use like this:
# first: Install additional apt-sources, keys etc
# second: Call apt-get update
# main:  Install packages, gems, configure files, etc
# last:  Start services (e.g. apache, gollum, jenkins, x2go)
notify { "site.pp for vagrant/elexis": }

class { 'apt': proxy_host => "172.25.1.61", proxy_port => 3142, }

# I am not sure, whether I still need them
# I think, using puppetlabs-apt, make some lines obsolete (TODO: before 0.2)
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
# obsolete until here?

# Under Debian squeeze we must install rubygems as it was not yet part of the
# basic ruby package
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

# etckeeper is a nice utility which will track (each day or for each apt-get run) the changes
# in the /etc directory. Handy to know why suddenly a package does not work anymore!
include etckeeper # will define package git, too
package{  ['vim', 'vim-nox', 'vim-puppet', 'dlocate', 'mlocate', 'htop', 'curl', 'bzr', 'unzip']:
  ensure => present,
}

# The author's personal choice
exec {'set_vim_as_default_editor':
  command => 'update-alternatives --set editor /usr/bin/vim.nox',
  require => Package['vim-nox'],
  path    => "/usr/bin:/usr/sbin:/bin:/sbin",
}


# this allows you to experiment with different combination/usages 
import "nodes/*.pp"

node default {
    notify { "site.pp node default": }
}
