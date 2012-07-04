# Here we setup a few 2.1.7 related jenkins job configuration files
# TODO: Split this up into jenkins-base, user. Use ERB-templates for common tasks like poll, building.

class elexis::jenkins_2_1_7 {
  include jenkins
  jenkins::plugin {
    [ "mercurial", "subversion", "git", "ant", "buckminster", "build-timeout", "cvs", "disk-usage", "javadoc",
      "jobConfigHistory", "copy-to-slave", "locks-and-latches", "ssh-slaves", "ruby", "timestamper", ]:
  }

  # specify some default values for all files to be created,
  File {
    owner => 'jenkins',
    mode => '644',
    notify => Service['jenkins'],
    require => [Class["jenkins::package"], Package["jenkins"]]
  }

  file { '/var/lib/jenkins/jobs':
  ensure => directory, # so make this a directory
  }

  file { '/var/lib/jenkins/jobs/poll-elexis-addons-2.1.7':
  ensure => directory, # so make this a directory
  }

  file { '/var/lib/jenkins/jobs/poll-elexis-addons-2.1.7/config.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/poll-elexis-addons-2.1.7/config.xml',
  }

  file { '/var/lib/jenkins/jobs/poll-elexis-base-2.1.7':
  ensure => directory, # so make this a directory
  }
  file { '/var/lib/jenkins/jobs/poll-elexis-base-2.1.7/config.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/poll-elexis-base-2.1.7/config.xml',
  }

  file { '/var/lib/jenkins/jobs/elexis-2.1.7-ant':
  ensure => directory, # so make this a directory
  }
  file { '/var/lib/jenkins/jobs/elexis-2.1.7-ant/config_old_jenkins.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/elexis-2.1.7-ant/config.xml',
  }

  file { '/var/lib/jenkins/jobs/jubula-elexis-2.1.7':
  ensure => directory, # so make this a directory
  }
  file { '/var/lib/jenkins/jobs/jubula-elexis-2.1.7/config_old_jenkins.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/jubula-elexis-2.1.7/config.xml',
  }

  file { [ '/var/lib/jenkins/users', '/var/lib/jenkins/users/elexis']:
  ensure => directory, # so make this a directory
  }
  file { '/var/lib/jenkins/users/elexis/config.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/users/elexis.xml',
  }

}
