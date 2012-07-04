# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class elexis::praxis_wiki inherits elexis::common {

  package { ['make', 'libxslt-dev', 'libxml2-dev']:
    ensure => installed,
  }
  package{  ['gollum']:
    ensure => present,
    provider => gem,
    require => Package['make', 'libxslt-dev', 'libxml2-dev'],
  }

# gollum TODO: set default to .textile, see DefaultOptions  in lib/gollum/frontend/public/javascript/editor/gollum.editor.js
# Maybe done using a config.ru file inside the wiki!

#  gem('RedCloth', 'install',  nil, '--no-rdoc --no-ri') # add support for .textile

  $initFile =  '/etc/init.d/gollum'
  $vcsRoot = '/home/elexis/praxis_wiki'

  file  { $initFile:
    source => 'puppet:///modules/elexis/gollum.init',
    owner => 'root',
    group => 'root',
    mode  => 0754,
  }

  service { 'gollum':
    ensure => running,
    enable => true,
    hasstatus => false,
    hasrestart => false,
    require => [ File[$initFile], Vcsrepo[$vcsRoot], ],
  }

  vcsrepo {  "$vcsRoot":
      ensure => present,
      provider => git,
      owner => 'elexis',
      group => 'elexis',
      source => "https://github.com/ngiger/elexis-admin.wiki.git",
      require => Package['git'],
      notify => Service['gollum'],
  }
}
