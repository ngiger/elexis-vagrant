# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# get all the stuff needed to run elexis-bootstrap for Elexis 2.1.7

class elexis::elexis_bootstrap(
  $vcsRoot = "/home/elexis/elexis-bootstrap",
  $rubyVersion = 'jruby-1.6.7.2',
  $eclipseVersion = "$elexis::defaultEclipse",
  $baseURL = "$elexis::downloadURL/eclipse",
) inherits elexis::common {

  package { ['fop', 'ant', 'ant-contrib', 'mercurial']:
    ensure => latest
  }
  # texlive texinfo texlive-latex-extra texlive-lang-german 
  if (!defined(Elexis::Download_eclipse_version[$eclipseVersion])) {
    elexis::download_eclipse_version{"$eclipseVersion": baseURL => "$baseURL", }
  }
  
  vcsrepo {  "$vcsRoot":
      ensure => present,
      provider => hg,
      owner => 'elexis',
      group => 'elexis',
      source => "https://bitbucket.org/ngiger/elexis-bootstrap",
      require => [User['elexis'], Package['mercurial'] ],
  }  
  
  $P2_EXE = "/opt/eclipse/${elexis::defaultEclipse}/eclipse/"
  notify{"P2_EXE ist $P2_EXE": }
  file { "$vcsRoot/build_elexis_in_vagrant.sh":
    owner => 'elexis',
    group => 'elexis',
    content => template('elexis/build_elexis_in_vagrant.sh.erb'),
    require => Vcsrepo[$vcsRoot],
    mode => 0755,
  }
}
