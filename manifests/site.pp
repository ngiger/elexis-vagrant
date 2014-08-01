# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# stages are use like this:
# first: Install additional apt-sources, keys etc
# second: Call apt-get update
# main:  Install packages, gems, configure files, etc
# last:  Start services (e.g. apache, gollum, jenkins, x2go)

# tips for
# http://de.slideshare.net/DECK36/20140327-guugpuppetstory
# http://github.com/gini/puppet-git-hooks

# I am not sure, whether I still need them
# I think, using puppetlabs-apt, make some lines obsolete (TODO: before 0.2)
stage { 'initial': before => Stage['first'] }
stage { 'first': before => Stage['second'] }
stage { 'second': before => Stage['main'] }
stage { 'last': require => Stage['main'] }

node "basenode-vagrant" {
  notify{"XXXX: node basenode-vagrant inside site.pp": }
}

node "serverx" inherits "basenode-vagrant" {
  notify{"XXXX: node server inside site.pp": }
}
class { 'apt': 
  always_apt_update    => true,
  proxy_host           => hiera('elexis::apt_proxy_host', ''),
  proxy_port           => hiera('elexis::apt_proxy_port', '3142'),
  purge_sources_list   => true,
  purge_sources_list_d => true,
  purge_preferences_d  => true,
#  stage => first,
}

# http://docs.puppetlabs.com/hiera/1/complete_example.html
# replace inheritance with
# http://docs.puppetlabs.com/hiera/1/puppet.html#assigning-classes-to-nodes-with-hiera-hierainclude
# http://www.glennposton.com/posts/puppet_best_practices__environment_specific_configs
#   ---
#   :backends: - yaml
#   :hierarchy: - %{environment}/%{fqdn}
#               - %{environment}/%{calling_module}
#               - %{environment}
#               - common/%{calling_module}
#               - common
#   :yaml:
#     :datadir: /mnt/puppetmanifests/configuration
# securing data https://ask.puppetlabs.com/question/476/securely-storing-passwords-and-keys/ (eyaml) hiera-gpg
# https://github.com/gtmtechltd/hiera-eyaml-plaintext
# https://help.github.com/articles/remove-sensitive-data
# https://help.ubuntu.com/community/UnityLaunchersAndDesktopFiles#Adding_shortcuts_to_a_launcher
if $node =~ /ubuntu/ {
  notify{"apt-sources for ubuntu missing": }
} else {
  notify{"apt-sources for debian missing": }
  
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
}

group { "puppet": ensure => "present"}

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

$users_elexis        = hiera('users_elexis', [])
if ($users_elexis) { elexis::users  {"users_elexis": user_definition       => $users_elexis} }

node /default/ {
    notify { "\n\nsite.pp node default for hostname $hostname": }
}

# Some common stuff for the admin
if hiera('elexis::admin::ensure', false) { include elexis::admin }
if hiera('etckeeper::ensure', false) { include etckeeper }

# User setup. Choose between KDE and (gnome, unity: both not yet supported)
if hiera('kde::ensure', false)       { include kde }
ensure_resource('class', 'x2go',  {version => 'baikal', } )
if hiera('x2go::ensure', false)      { include x2go }

# stuff for the server
if hiera('elexis::praxis_wiki::ensure', false) { include elexis::praxis_wiki }
if hiera('apache::ensure', false) { include apache }
if hiera('dnsmasq::ensure', false) { include dnsmasq }

# development stuff
if hiera('eclipse::ensure', false)   { include eclipse }
#if hiera('buildr::ensure', false)    { include buildr }
if hiera('jubula::ensure', false)    { include jubula }

if false {
if hiera('elexis::install::OpenSource::ensure', false)  
{ 
  elexis::install  {"OpenSource":
    programURL             => hiera('elexis::install::OpenSource::programURL', 'please provide a correct URL'),
    version                => hiera('elexis::install::OpenSource::version',    'please provide a correct version'),
    installBase            => hiera('elexis::install::OpenSource::installBase', '/usr/local/elexis'),
  }
}

if hiera('elexis::install::Medelexis::ensure', false)  
{ 
  elexis::install {"Medelexis":
    programURL             => 'http://www.medelexis.ch/dl21.php?file=medelexis-linux',
    version                => 'current',
    installBase            => '/usr/local/medelexis',
  }
}
}

$display_manager =  hiera('X::display_manager', false)
if ($display_manager) { package{$display_manager:}
  service{$display_manager:
    ensure  => running,
    require => Package[$display_manager],
  }
}

$window_manager =  hiera('X::window_manager', false)
if ($window_manager) { package{$window_manager:} }

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

node "ubuntu" {
#  include unity and x2go server, java7 for Elexis Desktop
  include elexis::admin
  x2go::server {"x2go-server": ensure => true }
  include nfs::client
  include mysql::client
  include postgresql::client
  ensure_packages['gnome-session', 'gdm3', # gnome-control-center
    'openjdk-7-jre',
    'libreoffice-gtk3', 'libreoffice', 'libreoffice-l10n-de', 'libreoffice-l10n-fr',
    'iceweasel', 'iceweasel-l10n-de',
    'icedove',   'icedove-l10n-de',
  ]
  $nfs_server = hiera('nfs_server', '')
  if ("$nfs_server") {
    file{'/home.prxserver':  ensure => directory, }
    mount { '/home.prxserver':
      device  => "$nfs_server:/home",
      fstype => 'nfs',
      ensure  => "mounted",
      options => "defaults",
      atboot  => true,
      require => File['/home.prxserver'],
    }
    file{'/etc/puppet':  ensure => directory, }
    mount { '/etc/puppet':
      device  => "$nfs_server:/etc/puppet",
      fstype => 'nfs',
      ensure  => "mounted",
      options => "defaults",
      atboot  => true,
      require => File['/etc/puppet'],
    }
  }
}
node "ubuntu12" inherits "ubuntu" { }
