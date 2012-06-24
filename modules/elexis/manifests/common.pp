# Here we define a few packages which are common to all elexis instances
class elexis::common {

  include java
  package{  ['vim', 'vim-nox', 'git', 'etckeeper', 'puppet']:
    ensure => present,
  }
}
