# Here we define a few packages which are common to all elexis instances
class elexis::devel inherits elexis::common {

  include elexis::client
  include elexis::server
  package { ['ant', 'subversion', 'mercurial']:
    ensure => latest
  }
  include eclipse
#  include jubula # TODO:
#  include buildr # TODO:
}
