# Here we define all needed stuff to bring up a complete
# server environment for Elexis

class elexis::server inherits elexis::common {

  package{  ['cups', 'cups-bsd']:
    ensure => present,
  }
    class { 'mysql::server':
	config_hash => { 'root_password' => 'elexisTest' }
    }

    database { 'mysql':
      ensure  => 'present',
      charset => 'utf8',
    }

    mysql::db { 'myElexis':
      user     => 'elexis',
      password => 'elexisTest',
      host     => 'localhost',
      grant    => ['all'],
    }

# TODO: Add grants for all Elexis users!
    database_grant { ['arzt@localhost/myElexis', 'niklaus@localhost/myElexis', 'vagrant@localhost/myElexis']:
      privileges => ['all'] ,
    }

# see http://puppetlabs.com/blog/module-of-the-week-puppetlabs-mysql-mysql-management/
#  include postgresql # TODO:
 # define backup # TODO: Dritte Priorität
 # define test-deb (anonymized) # TODO: Vierte Priorität (Nice to have)
}
