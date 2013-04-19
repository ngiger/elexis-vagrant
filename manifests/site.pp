# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

# stages are use like this:
# first: Install additional apt-sources, keys etc
# second: Call apt-get update
# main:  Install packages, gems, configure files, etc
# last:  Start services (e.g. apache, gollum, jenkins, x2go)

# I am not sure, whether I still need them
# I think, using puppetlabs-apt, make some lines obsolete (TODO: before 0.2)
stage { 'initial': before => Stage['first'] }
stage { 'first': before => Stage['second'] }
stage { 'second': before => Stage['main'] }
stage { 'last': require => Stage['main'] }

class { 'apt': }

apt::source { 'debian_wheezy':
  location          => hiera('apt::source:location', 'http://mirror.switch.ch/ftp/mirror/debian/'),
  release           => hiera('apt::source:release', 'wheezy'),
  repos             => hiera('apt::source:repos', 'main contrib non-free'),
#  required_packages => hiera('apt::source:required_packages', 'debian-keyring debian-archive-keyring'),
#  key               => hiera('apt::source:key', '55BE302B'),
#  key_server        => hiera('apt::source:key_server', 'subkeys.pgp.net'),
#  pin               => hiera('apt::source:pin', '-10'),
  include_src       => hiera('apt::source:include_src', true),
}

apt::source { 'debian_security':
  location          => hiera('apt::source:security:location', 'http://security.debian.org/'),
  release           => hiera('apt::source:security:release', 'wheezy/updates'),
  repos             => hiera('apt::source:security:repos', 'main contrib non-free'),
  include_src       => hiera('apt::source:security:include_src', true),
}
    
group { "puppet": ensure => "present", gid => 7777}

# class apt_get_update {    
#     exec{'apt_get_update':
#       command => "apt-get update",
#       path    => "/usr/bin:/usr/sbin:/bin:/sbin",
#       refreshonly => true,
#     }
# }

class { ['ensureLibShadow']: stage => first; }
# class {'apt_get_update': stage => initial; }

# Under Debian squeeze we must install rubygems as it was not yet part of the
# basic ruby package
# include apt_get_update

class ensureLibShadow{
  case $rubyversion {
    '1.8.7' : {
#      notify { "ruby version $rubyversion needs rubygems": }
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
  package{ [ hiera('editor:package') ]:
    ensure => present,
  }
  
  exec {'set_default_editor':
    command => "update-alternatives --set editor ${editor_default}",
    require => Package[hiera('editor:package')],
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
  }  
}
node default {
    # notify { "\n\nsite.pp node default for hostname $hostname": }
}

# Some common stuff for the admin
if hiera('etckeeper::ensure', false) { include etckeeper }

# User setup. Choose between KDE and (gnome, unity: both not yet supported)
if hiera('kde::ensure', false)       { include kde }
if hiera('sshd::ensure', false)      { include sshd }
if hiera('x2go::ensure', false)      { include x2go }

# stuff for the server
if hiera('elexis::praxis_wiki::ensure', false) { include elexis::praxis_wiki }
if hiera('apache::ensure', false) { include apache }

# usually only on database is ensure
if hiera('elexis:postgres::ensure', false)  { include elexis::postgresql_server }
if hiera('elexis:mysql::ensure',    false)  { include elexis::mysql_server }
# TODO: add backup postgres-server

# development stuff
if hiera('eclipse::ensure', false)   { include eclipse }
if hiera('buildr::ensure', false)    { include buildr }
if hiera('jubula::ensure', false)    { include jubula }
# TODO: add a possibility to add some more private stuff
include hiera('private_modules', [])  

# elexis::server
# elexis::jenkins_2_1_7
# elexis::praxis_wiki
# x2go::server and x2go::client
# elexis::client
# elexis::app via http://ngiger.dyndns.org/jenkins/job/elexis-2.1.7-Buildr/lastSuccessfulBuild/artifact/deploy/elexis-installer.jar 
# medelexis::app via http://www.medelexis.ch/dl21.php?file=medelexis-linux

import "nodes/*.pp"

$res = hiera('import:xxxxprivate:nodes', false)
if $res {
    #notify { "\nimporting private nodes res ist $res": }
#    import "../private/nodes/*.pp";
}

