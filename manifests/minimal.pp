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

class etc_hiera_yaml {
#  file {"/etc/puppet/hiera.yaml": source => "puppet:///modules/elexis/hiera.yaml", } 
  
}

