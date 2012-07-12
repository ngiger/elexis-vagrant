# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# Here we setup a few elexis related jenkins job configuration files
# TODO: Jubula needs a 32-bit Java (and a 32-bit Elexis)
# TODO: 32-bit java, eg. sudo apt-get install openjdk-6-jdk:i386 openjdk-6-jre-headless:i386

class elexis::jenkins_commons inherits elexis::common {
  require jenkins
  notify { "elexis::jenkins_commons: ${jenkins::jenkinsRoot}/downloads": }
  $downloadDir    =  "${jenkins::jenkinsRoot}/downloads"
  $jobsDir        =  "${jenkins::jenkinsRoot}/jobs"
  $neededUsers    = User[$jenkins::jenkinsUser,'elexis']
  $elexisBaseURL  = "http://http://hg.sourceforge.net/hgweb/elexis"

  file { [$jobsDir, $downloadDir, "${jenkins::jenkinsRoot}/.ssh"]:
    owner => 'jenkins',
    mode => '644',
    ensure => directory, # so make this a directory
  }

  # include jenkins::repo::debian # This does not work under Ubuntu to get the latest version!!
#  class { 'jenkins': version => latest }
  include jenkins
  include jenkins::package
  include jenkins::repo::debian
  include apt
  include jenkins::service
  jenkins::plugin {
    [ "mercurial", "subversion", "git", "ant", "buckminster", "build-timeout", "cvs", "disk-usage", "javadoc",
      "jobConfigHistory", "copy-to-slave", "locks-and-latches", "ssh-slaves", "ruby", "timestamper","xvnc" ]:
  }

  # specify some default values for all files to be created,
  File {
    owner => 'jenkins',
    mode => '644',
    notify => Service['jenkins'],
    require => [User['jenkins']]
  }
  
  file { [ '/var/lib/jenkins/users', '/var/lib/jenkins/users/elexis']:
    ensure => directory, # so make this a directory
  }

  file { '/var/lib/jenkins/users/elexis/config.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/users/elexis.xml',
  }

  file { '/var/lib/jenkins/config.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/config.xml',
  }

  include elexis::latex # needed to create Elexis documentation in the ant jobs
  
}
