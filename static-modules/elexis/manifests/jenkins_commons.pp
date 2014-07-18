# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# Here we setup a few elexis related jenkins job configuration files
# TODO: Jubula needs a 32-bit Java (and a 32-bit Elexis)
# TODO: 32-bit java, eg. sudo apt-get install openjdk-6-jdk:i386 openjdk-6-jre-headless:i386

class elexis::jenkins_commons(
) inherits elexis::common {
  require jenkins
  $neededUsers    = User['jenkins'] # ,'elexis'

  file { [$jenkinsJobsDir]:
    owner => 'jenkins',
    mode => '644',
    ensure => directory, # so make this a directory
  }

  # include jenkins::repo::debian # This does not work under Ubuntu to get the latest version!!
  include jenkins
  include jenkins::package
  include jenkins::repo::debian
  include apt
  include jenkins::service
  include elexis::jubula_elexis

  $pluginsForElexis = ["mercurial", "subversion", "git", "ant", "buckminster", "build-timeout", "cvs", "disk-usage", "javadoc", "jobConfigHistory", "copy-to-slave", "locks-and-latches", "ssh-slaves", "ruby", "timestamper","xvnc" ] 

  jenkins::plugin { $pluginsForElexis: }
  
  # specify some default values for all files to be created,
  File {
    owner => 'jenkins',
    mode => '644',
    notify => Service['jenkins'],
    require => [User['jenkins']],
  }
  
  file { ["$elexis::jenkinsRoot/users", "$elexis::jenkinsRoot/users/elexis"]:
    ensure => directory, # so make this a directory
  }

  file { "$elexis::jenkinsRoot/users/elexis/config.xml":
    ensure => present,
    source => 'puppet:///modules/elexis/users/elexis.xml',
    replace => false,  # If the user changes the setup, don't overwrite it
  }

  file { "$elexis::jenkinsRoot/config.xml":
    ensure => present,
    source => 'puppet:///modules/elexis/config.xml',
    replace => false,  # If the user changes the setup, don't overwrite it
  }
  # Our config.xml must be written, before we install jenkins, as the jenkins package
  # will install it's own version.
  Package['jenkins'] <- File["$elexis::jenkinsRoot/config.xml"]

  include elexis::latex # needed to create Elexis documentation in the ant jobs
  Elexis::Latex { notify => Service['jenkins'] }

}
