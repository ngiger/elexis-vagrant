# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

# stages are use like this:
# first: Install additional apt-sources, keys etc
# second: Call apt-get update
# main:  Install packages, gems, configure files, etc
# last:  Start services (e.g. apache, gollum, jenkins, x2go)

# I am not sure, whether I still need them
# I think, using puppetlabs-apt, make some lines obsolete (TODO: before 0.2)
stage { 'first': before => Stage['second'] }
stage { 'second': before => Stage['main'] }
stage { 'last': require => Stage['main'] }
class { 'apt': proxy_host => "172.25.1.77", proxy_port => 3142}

group { "puppet": ensure => "present", }

class apt_get_update {
    file{"/etc/apt/apt.conf":
        content => 'Acquire::http::Proxy "http://172.25.1.77:3142"  ;;'
    }
    exec{'apt_get_update':
      command => "apt-get update",
      path    => "/usr/bin:/usr/sbin:/bin:/sbin",
      refreshonly => true,
    }
}

class {
  ['ensureLibShadow']: stage => first;
#  "main2":  stage => main;
#  "last":  stage => last;
}

class {
      'apt_get_update': stage => first;
#      'apache':   stage => last;
}

# Under Debian squeeze we must install rubygems as it was not yet part of the
# basic ruby package
include apt_get_update

class ensureLibShadow{
  case $rubyversion {
    '1.8.7' : {
      notify { "ruby version $rubyversion needs rubygems": }
      package { ['rubygems','libshadow-ruby1.8']: # libshadow-ruby1.8 needed to manage user passwords!
        ensure => present,
      }
    }
    default : { }
  }
}

# etckeeper is a nice utility which will track (each day or for each apt-get run) the changes
# in the /etc directory. Handy to know why suddenly a package does not work anymore!
include etckeeper # will define package git, too
package{  ['dlocate', 'mlocate', 'htop', 'curl', 'bzr', 'unzip']:
  ensure => present,
}

# The author's personal choice
if hiera('editor:default', false) {
  $editor_default = hiera('editor:default')
  notify { "The author's personal choice is ${editor_default}": }
  
  package{ [ hiera('editor:package') ]:
    ensure => present,
  }
  
  exec {'set_default_editor':
    command => "update-alternatives --set editor ${editor_default}",
    require => Package[hiera('editor:package')],
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
  }  
}
else {
  notify { "no default editor specified": }
}

# Some common stuff for the admin
if hiera('etckeeper:included', false) { include etckeeper }

# User setup. Choose between KDE and (gnome, unity: both not yet supported)
if hiera('kde:included', false)       { include kde }
if hiera('sshd:included', false)      { include sshd }
if hiera('x2go:included', false)      { include x2go }

# stuff for the server
if hiera('elexis::praxis_wiki:included', false) { include elexis::praxis_wiki }

# usually only on database is included
if hiera('elexis:postgres:included', false)  { include elexis::postgresql_server }
if hiera('elexis:mysql:included',    false)  { include elexis::mysql_server }
# TODO: add backup postgres-server

# development stuff
if hiera('eclipse:included', false)   { include eclipse }
if hiera('buildr:included', false)    { include buildr }
if hiera('jubula:included', false)    { include jubula }
# TODO: add a possibility to add some more private stuff
include hiera('private_modules', [])  

# elexis::server
# elexis::jenkins_2_1_7
# elexis::praxis_wiki
# x2go::server and x2go::client
# elexis::client
# elexis::app via http://ngiger.dyndns.org/jenkins/job/elexis-2.1.7-Buildr/lastSuccessfulBuild/artifact/deploy/elexis-installer.jar 
# medelexis::app via http://www.medelexis.ch/dl21.php?file=medelexis-linux

