# get our apps for VCS

class elexis::vcs_apps inherits elexis::common {

  include git # git is a separate module
  package { ['ant', 'subversion', 'mercurial', 'mercurial-git']:
    ensure => latest
  }
}
