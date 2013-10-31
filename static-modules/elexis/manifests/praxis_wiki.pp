# Here we define all needed stuff to bring up a Wiki for an Elexis practice
include git

class elexis::praxis_wiki(
  $vcsRoot = '/opt/src/elexis-admin.wiki'
) inherits elexis::common {
  $ensure =hiera('elexis::praxis_wiki::ensure', absent)
  $initFile =  '/etc/init.d/gollum'

  ensure_packages(['make', 'libxslt1-dev', 'libxml2-dev'])
  package{  ['gollum', # markdowns is currently well supported, including live editing
    'RedCloth',  # to support textile, but no live editing at the moment
    'wikicloth'  # to support mediawiki, but no live editing at the moment
    ]:
    ensure => $ensure,
    provider => gem,
    require => Package['make', 'libxslt1-dev', 'libxml2-dev'],
  }

# gollum TODO: set default to .textile, see DefaultOptions  in lib/gollum/frontend/public/javascript/editor/gollum.editor.js
# Maybe done using a config.ru file inside the wiki!
  vcsrepo {  "$vcsRoot":
      ensure => $ensure,
      provider => git,
      owner => 'elexis',
      group => 'elexis',
      source => "https://github.com/ngiger/elexis-admin.wiki.git",
      require => [User['elexis'], ], # Package['git'],
  }
  $local_bin = '/usr/local/bin'
  ensure_resource('file', $local_bin, { ensure => directory} )
  $gollum_runner = "${local_bin}/start_praxis_wiki.sh"
  $gollum_name     = "praxis_wiki"
  $gollum_run      = "/var/lib/service/$gollum_name/run"
  if ("$ensure" == absent) {
    file{  ["$gollum_runner"]:   ensure => absent, }
    $service_status = stopped
  } else {
    $service_status   = running
    file{"$gollum_runner":
      content => "#!/bin/bash
sudo -iHu elexis gollum $vcsRoot &> $vcsRoot/gollum.log
",
      owner => 'elexis',
      group => 'elexis',
      require => [User['elexis'], File["$local_bin"]],
      mode    => 0755,  
    }
  }
  exec{ "$gollum_run":
    command => "$elexis::params::create_service_script elexis $gollum_name $gollum_runner",
    path => "/usr/local/bin:/usr/bin:/bin",
    require => [
      File["$elexis::params::create_service_script", "$gollum_runner"],
      User["elexis"],
      Package['gollum'],
    ],
    creates => "$gollum_run",
    user => 'root',
  }        
  
  service{"$gollum_name":
    ensure => $service_status,
    provider => "daemontools",
    path    => "$service_path",
    hasrestart => true,
    subscribe  => Exec["$gollum_run"],
    require    => Exec["$gollum_run"], 
  }
 
}
