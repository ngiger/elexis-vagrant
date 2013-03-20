# Here we define all needed stuff to bring up a complete
# PostgreSQL server environment for Elexis
# https://puppetlabs.com/blog/module-of-the-week-inkling-postgresql/
# github: https://github.com/puppetlabs/puppet-postgresql 

# with the default values you can afterward connect as follows to the DB
# psql elexis -U elexis -h localhost --password  # pw is elexisTest

notify{"ng 55":}
include postgresql::server
include postgresql::client # only needed for a database_user

class elexis::pg_server(){
 class {'postgresql::server':
  config_hash => {
    'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    'ip_mask_allow_all_users'    => '0.0.0.0/0',
    'listen_addresses'           => '*',
    'ipv4acls'                   => ['hostssl all johndoe 192.168.0.0/24 cert'],
    'manage_redhat_firewall'     => false,
    'postgres_password'          => 'ng!',
  },
  }
  postgresql::db { 'elexis':
    user     => 'elexis',
    password => 'elexisTest',
#    require       => Class['postgresql::server'],
  }
  
}

class elexis::pg_users(){
  include postgresql::client
  postgresql::database_user{'marmot':
    password_hash => postgresql_password('marmot', 'foo'),
  }

  postgresql::role{'dan':
    password_hash => postgresql_password('dan', 'foo'),
    createdb => true,
    login => true,
    createrole => true,
    superuser => true,
  }
  postgresql::database_grant{'dan':
    privilege   => 'ALL',
    db          => 'elexis',
    role        => 'dan',
    require => [ Postgresql::Role['dan'], Postgresql::Db['elexis'] ],
  }
}