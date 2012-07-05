# Here we define all needed stuff to bring up a complete
# PostgreSQL server environment for Elexis

# for PostgreSQL use https://github.com/uggedal/puppet-module-postgresql
# or https://github.com/KrisBuytaert/puppet-postgres/ (creates db & user)
# https://github.com/example42/puppet-postgresql (includes firewall)
# https://github.com/akumria/puppet-postgresql (seems polished, user, db, grants)
# https://github.com/inkling/puppet-postgresql low version 0.0.1, but has spec tests (and a Vagrantfile!)

# https://github.com/jedi4ever/puppet-homebrew
# https://github.com/kelseyhightower/puppet-homebrew


class elexis::postgresql_server inherits elexis::common {
#  include postgresql
  class {'postgresql':  } # installs the client
  class {'postgresql::server':
    listen => "10.11.12.13", # for vagrant we use eth1
    port   => 5432
 } # installs the server

  postgresql::db { 'elexis':
      owner    => 'elexis',
      password => 'elexisTest',
#      locale   => 'de_CH',
      encoding => 'UTF-8',
  }

    pg_user {'arzt':
	ensure   => present,
	password => 'elexisTest',
    }
}
