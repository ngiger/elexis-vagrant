# Here we define all needed stuff to bring up a Wiki for an Elexis practice
include git

class elexis::praxis_wiki inherits elexis::common {
  $initFile =  '/etc/init.d/gollum'
  $vcsRoot = '/home/elexis/praxis_wiki'

  ensure_packages(['make', 'libxslt1-dev', 'libxml2-dev'])
  package{  ['gollum', # markdowns is currently well supported, including live editing
    'RedCloth',  # to support textile, but no live editing at the moment
    'wikicloth'  # to support mediawiki, but no live editing at the moment
    ]:
    ensure => present,
    provider => gem,
    require => Package['make', 'libxslt1-dev', 'libxml2-dev'],
  }

# gollum TODO: set default to .textile, see DefaultOptions  in lib/gollum/frontend/public/javascript/editor/gollum.editor.js
# Maybe done using a config.ru file inside the wiki!

  file  { $initFile:
    content => template('elexis/gollum.init.erb'),
    owner => 'root',
    group => 'root',
    mode  => 0754,
  }

  vcsrepo {  "$vcsRoot":
      ensure => present,
      provider => git,
      owner => 'elexis',
      group => 'elexis',
      source => "https://github.com/ngiger/elexis-admin.wiki.git",
      require => [User['elexis'], ], # Package['git'],
  }
}

class elexis::praxis_wiki_service inherits elexis::praxis_wiki {

  service { 'gollum':
    ensure => running,
    enable => true,
    hasstatus => false,
    hasrestart => false,
  }
}

class {'elexis::praxis_wiki_service':stage => deploy_app; }
