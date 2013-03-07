# Here we define all needed stuff to bring up a complete
# server environment for Elexis

# for PostgreSQL use https://github.com/uggedal/puppet-module-postgresql
# or https://github.com/KrisBuytaert/puppet-postgres/ (creates db & user)
# https://github.com/example42/puppet-postgresql (includes firewall)
# https://github.com/akumria/puppet-postgresql (seems polished, user, db, grants)
# https://github.com/inkling/puppet-postgresql low version 0.0.1, but has spec tests (and a Vagrantfile!)

# https://github.com/jedi4ever/puppet-homebrew
# https://github.com/kelseyhightower/puppet-homebrew
class elexis::server inherits elexis::common {

  # With this file we ensure that the mysql root password is elexisTest!
  file { '/etc/mysql/debian.cnf':
    ensure => present,
    owner => 'root',
    mode => '640',
    source => 'puppet:///modules/elexis/debian.cnf',
  }

  notify { "Granting for Elexis MySQL database": }
  package{  ['cups', 'cups-bsd']:
    ensure => present,
  }
    class { 'mysql::server':
    package_name  =>  hiera('mysql::server:package_name', 'mysql-server-5.5'),
    config_hash => { 'root_password' => hiera('mysql::server:root_password', 'elexisTest') } ,
    }

    mysql::db { 'elexis':
      user     => hiera('mysql::db:elexis:user',     'elexis'),
      password => hiera('mysql::db:elexis:password', 'elexisTest') ,
      host     => 'localhost',
      grant    => ['all']
    }

  database_user{ 'vagrant@localhost':
    ensure        => present,
    password_hash => mysql_password(hiera('mysql::db:user:vagrant:password', 'vagrant')),
    require       => Class['mysql::server'],
  }

  database_user{ 'niklaus@localhost':
    ensure        => present,
    password_hash => mysql_password(hiera('mysql::db:user:giger:password', 'giger')),
    require       => Class['mysql::server'],
  }

  database_user{ 'arzt@localhost':
    ensure        => present,
    password_hash => mysql_password(hiera('mysql::db:user:arzt:password', 'aeskulap')),
    require       => Class['mysql::server'],
  }

# TODO: Add grants for all Elexis users!
    database_grant { ['arzt@localhost/elexis', 'niklaus@localhost/elexis', 'vagrant@localhost/elexis']:
      privileges => ['all'] ,
    }

# see http://puppetlabs.com/blog/module-of-the-week-puppetlabs-mysql-mysql-management/
#  include postgresql # TODO:
 # define backup # TODO: Dritte Priorität
 # define test-deb (anonymized) # TODO: Vierte Priorität (Nice to have)
}
