# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# get all the stuff needed to run elexis-bootstrap for Elexis 2.1.7

class elexis::bootstrap inherits elexis::commons (
  $vcsRoot = "/home/elexis/elexis-bootstrap",
  $rubyVersion = 'jruby-1.6.7.2',
  $eclipseVersion = '1.0'
  $baseURL = "$elexis::downloadURL/eclipse"
    )
{
  include java6
  include elexis::vcs_app
  include elexis::rvm
  include elexis::jruby
  
  package { ['fop', 'ant', 'ant-contrib ']:
    ensure => latest
  }
  # texlive texinfo texlive-latex-extra texlive-lang-german 
  if (!defined(Elexis::Download_eclipse_version[$eclipseVersion])) {
    elexis::download_eclipse_version{$eclipseVersion:
      baseURL => "$baseURL",
    }
  }
  
  rvm_system_ruby {
      'jruby-1.6.7.2':
      ensure => 'present',
      default_use => false;
  }
  
  rvm_gemset {
    "jruby-1.6.7.2@elexis_bootstrap":
      ensure => present,
      require => Rvm_system_ruby['jruby-1.6.7.2'];
  }
  rvm_gem {
    'jruby-1.6.7.2@elexis_bootstrap/bundler':
      ensure => '1.0.21',
      require => Rvm_gemset['jruby-1.6.7.2@elexis_bootstrap'];
  }
  
}

class elexis::jenkins_commons inherits elexis::common {
  require jenkins
  notify { "elexis::jenkins_commons: ${jenkins::jenkinsRoot}/downloads": }
  $downloadDir    =  "${jenkins::jenkinsRoot}/downloads"
  $jobsDir        =  "${jenkins::jenkinsRoot}/jobs"
  $neededUsers    = User[$jenkins::jenkinsUser,'elexis']
  $elexisBaseURL  = "http://hg.sourceforge.net/hgweb/elexis"

  file { [$jobsDir, $downloadDir]:
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
  include elexis::jubula_elexis
#  include elexis::postgresql_server # we want to be able to test with postgresql, too

  $pluginsForElexis = ["mercurial", "subversion", "git", "ant", "buckminster", "build-timeout", "cvs", "disk-usage", "javadoc", "jobConfigHistory", "copy-to-slave", "locks-and-latches", "ssh-slaves", "ruby", "timestamper","xvnc" ] 

  jenkins::plugin { $pluginsForElexis: }
  
  # specify some default values for all files to be created,
  File {
    owner => 'jenkins',
    mode => '644',
    notify => Service['jenkins'],
    require => [User['jenkins']],
  }
  
  file { [ "${jenkins::jenkinsRoot}/users", "${jenkins::jenkinsRoot}/users/elexis"]:
    ensure => directory, # so make this a directory
  }

  file { "${jenkins::jenkinsRoot}/users/elexis/config.xml":
    ensure => present,
    source => 'puppet:///modules/elexis/users/elexis.xml',
    replace => false,  # If the user changes the setup, don't overwrite it
  }

  file { "${jenkins::jenkinsRoot}/config.xml":
    ensure => present,
    source => 'puppet:///modules/elexis/config.xml',
    replace => false,  # If the user changes the setup, don't overwrite it
  }
  # Our config.xml must be written, before we install jenkins, as the jenkins package
  # will install it's own version.
  Package['jenkins'] <- File["${jenkins::jenkinsRoot}/config.xml"]

  include elexis::latex # needed to create Elexis documentation in the ant jobs
  Elexis::Latex { notify => Service['jenkins'] }

}
