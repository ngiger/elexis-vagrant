# Here we define a few packages which are common to all elexis instances
class elexis::devel inherits elexis::common {

  include elexis::client
  include elexis::server
  package { ['ant', 'subversion', 'mercurial']:
    ensure => latest
  }
  include eclipse
  include jenkins
  include elexis::jenkins_2_1_7
  $vcsRoot = '/home/elexis'
  file { $vcsRoot:
    ensure => directory,
  }
  vcsrepo { "$vcsRoot/elexis-bootstrap":
      ensure => present,
      provider => hg,
      require => [ File[$vcsRoot], Package['mercurial'], ],
      source => "https://bitbucket.org/ngiger/elexis-bootstrap",
  }
#  include elexis::jenkins_2_2_dev_jpa # TODO: Zweite Priorität , dito 2.1.6/zdavatz and buildr)
  include jubula # TODO: Zweite Priorität
#  include buildr # TODO: Dritte Priorität, da mit 2.1.7 mit ant gebuildet werden kann
}
