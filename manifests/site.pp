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

# require apt::ppa
# require apt::sources
require apt

if hiera('etckeeper::ensure', false) { include etckeeper }

$hostname_classes = hiera("classes_for_${hostname}", '')

if ("classes_for_$hostname" != "") {
  file{"/etc/hostname_classes":
    content => "$hostname_classes\n",
#      require => [ Class[$hostname_classes], ] # fails when more than 1 class given, eg x2go::common
  }
  include $hostname_classes
}

# https://forge.puppetlabs.com/puppetlabs/stdlib
# file_line: This resource ensures that a given line is contained within a file. You can also use "match" to replace existing lines.
# loadyaml Load a YAML file containing an array, string, or hash, and return the data in the corresponding native data type.
#  str2saltedsha512 This converts a string to a salted-SHA512 password hash (which is used for OS X versions >= 10.7). Given any simple string, you will get a hex version of a salted-SHA512 password hash that can be inserted into your Puppet manifests as a valid password attribute.

# unix chpasswd [options] DESCRIPTION     The chpasswd command reads a list of user name and password pairs from standard input   and uses this information to update a group of existing users.
# Each line is of the format:
# user_name:password

$hostname_packages = hiera("packages_for_${hostname}", [])
if ("packages_for_$hostname" != "") {
  file{"/etc/packages_for_$hostname":
    content => join($hostname_packages, "\n"),
  }
  ensure_packages[$hostname_packages]
}

$admin_packages = hiera("packages_for_admin", [])
if ("packages_for_$admin" != "") {
  file{"/etc/packages_for_$admin":
    content => join($admin_packages, "\n"),
  }
  ensure_packages[$admin_packages]
}

$users_elexis        = hiera('users_elexis', [])
if ($users_elexis) { elexis::users  {"users_elexis": user_definition => $users_elexis} }

# Some common stuff for the admin
if hiera('elexis::admin::ensure', false) { include elexis::admin }

# User setup. Choose between KDE and (gnome, unity: both not yet supported)
if hiera('kde::ensure', false)       { include kde }

# ensure_resource('class', 'x2go',  {version => 'baikal', } )

if hiera('x2go::ensure', false)      { include x2go }
 
# stuff for the server
if hiera('elexis::praxis_wiki::ensure', false) { include elexis::praxis_wiki }
if hiera('apache::ensure', false) { include apache }
if hiera('dnsmasq::ensure', false) { include dnsmasq }

# development stuff not active at this moment
# if hiera('eclipse::ensure', false)   { include eclipse }
# if hiera('jubula::ensure', false)    { include jubula }

