# Things to setup to be able to run Jubula tests for Elexis
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::jubula_elexis  inherits elexis::common {

  class {"jubula":
    jubulaURL => "${downloadURL}/jubula/jubula_setup_5.2.00266.sh",
    destDir =>  '/opt/jubula_5.2.00266',
    setupSh => '/opt/downloads/jubula_5.2.00266.sh'
  }
    
  include elexis::server # we need also the elexis-db
  
  mysql::db { 'jubula_vagrant':
    user     => 'elexis',
    password => 'elexisTest',
    host     => 'localhost',
    grant    => ['all'],
  }

  include elexis::jenkins_slave # we need also a jenkins slave  
  
}
# vi: set ft=ruby :