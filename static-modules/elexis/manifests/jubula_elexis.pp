# Things to setup to be able to run Jubula tests for Elexis
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::jubula_elexis  inherits elexis::common {

  $jubula_version = '6.0.01011'
  
  class {"jubula":
    jubulaURL => "$elexis::downloadURL/jubula/jubula_setup_${jubula_version}.sh",
    destDir   => "/opt/jubula_${jubula_version}",
    setupSh   => "/opt/downloads/jubula_${jubula_version}.sh",
  }
    
  include elexis::mysql_server # we need also a MySQL-database
  
  mysql::db { 'jubula_vagrant':
    user     => 'elexis',
    password => 'elexisTest',
    host     => 'localhost',
    grant    => ['all'],
  }

  include elexis::jenkins_slave # we need also a jenkins slave  
  
}
# vi: set ft=ruby :