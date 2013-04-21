# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# get all the stuff needed to run elexis-bootstrap for Elexis 2.1.7

class elexis::elexis_bootstrap(
  $vcsRoot = "/home/elexis/elexis-bootstrap",
  $rubyVersion = 'jruby-1.6.7.2',
  $eclipseVersion = "$elexis::defaultEclipse"
  $baseURL = "$elexis::downloadURL/eclipse"
) inherits elexis::common {
#  include java6
  include elexis::rvm
  
  package { ['fop', 'ant', 'ant-contrib', 'mercurial']:
    ensure => latest
  }
  # texlive texinfo texlive-latex-extra texlive-lang-german 
  if (!defined(Elexis::Download_eclipse_version[$eclipseVersion])) {
    elexis::download_eclipse_version{"$eclipseVersion": baseURL => "$baseURL", }
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

  vcsrepo {  "$vcsRoot":
      ensure => present,
      provider => hg,
      owner => 'elexis',
      group => 'elexis',
      source => "https://bitbucket.org/ngiger/elexis-bootstrap",
      require => [User['elexis'],Package['mercurial'] ],
  }  
  
}
