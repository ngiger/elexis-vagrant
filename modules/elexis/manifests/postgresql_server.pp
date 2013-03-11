# Here we define all needed stuff to bring up a complete
# PostgreSQL server environment for Elexis
# https://puppetlabs.com/blog/module-of-the-week-inkling-postgresql/
# github: https://github.com/puppetlabs/puppet-postgresql 

# with the default values you can afterward connect as follows to the DB
# psql elexis -U elexis -h localhost --password  # pw is elexisTest

class { 'postgresql':
  charset => 'UTF8',
  locale  => 'en_US',
}

class elexis::postgresql_server(
  $db_backup_dir      = '/home/backup/postgresql',
  $db_main_name      = 'elexis',
  $db_main_user      = 'elexis',
  $db_main_password  = 'elexisTest',
  $db_test_name      = 'tst_db',
  $db_pg_dump_script = '/usr/local/bin/pg_dump_elexis.rb',
){

}

class elexis::postgresql_server inherits elexis::common {

  file  { "${db_backup_dir}/wal/":
    ensure => directory,
    owner  => 'postgres',
    mode   => 0755,
  }
  package { 'postgresql-contrib':
    ensure => present,
    }
  class {'postgresql::server':
    config_hash => {
        'ip_mask_deny_postgres_user' => hiera('postgres::ip_mask_deny_postgres_user', '0.0.0.0/32'),
        'ip_mask_allow_all_users'    => hiera('postgres::ip_mask_allow_all_users', '0.0.0.0/0'),
        'listen_addresses' => '*',
        'manage_redhat_firewall' => hiera('postgres::manage_redhat_firewall', false),
        'postgres_password' => hiera('postgres::password', 'postgres'),

        # archive_command: command to use to archive a logfile segment
        
    },
    require => Package['postgresql-contrib'],
  }
  $postgresql_conf_path = $::postgresql::params::datadir
#  $pg_user =              $::postgresql::params::user, group => owner  =>  $::postgresql::params::group,
  
  notify { "Is this correct ${postgresql_conf_path}/postgresql_puppet_extras.conf":}
  file {"${postgresql_conf_path}/postgresql_puppet_extras.conf":
    content => template("elexis/postgresql_puppet_extras.conf.erb"),
    owner  =>  $::postgresql::params::user, group => $::postgresql::params::group,
    mode   => 0644, 
    }
    
  postgresql::pg_hba_rule { 'allow application network to access app database':
    description => "Open up postgresql for access from 200.1.2.0/24",
    type => 'host',
    database => 'app',
    user => 'app',
    address => '200.1.2.0/24',
    auth_method => 'md5',
  }  
  # host       database  user  CIDR-address  auth-method  [auth-option]
  # host    elexis-test elexis      192.168.1.0/24        md5
  
  # Don't know how to backup having only the md5 sum of the password
  # create postgresql_password using 
  # puppet apply --execute 'notify { "test": message => postgresql_password("username", "password") }'
  # md5e0925320617bda379cf9db294f07caf2 is for elexis/elexisTest
                                      
  if $db_main_name {
    postgresql::db { "$db_main_name":
      charset => 'utf8',      
      user     => $db_main_user,
      password => $db_main_password,
      grant    => hiera('postgresql::db:elexis:grant', 'all') 
    }

    postgresql::database_grant{"$db_main_name":
      privilege   => 'ALL',
      db          => "$db_main_name",
      role        => "$db_main_user",
    }
  }

  if $db_test_name {
    postgresql::db { "$db_test_name":
      charset => 'utf8',      
      user     => $db_main_user,
      password => $db_main_password,
      grant    => hiera('postgresql::db:elexis:grant', 'all')
    }

    postgresql::database_grant{"$db_test_name":
      privilege   => 'ALL',
      db          => "$db_test_name",
      role        => "$db_main_user",
    }        
  }

  file {"$db_pg_dump_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_dump_elexis.rb.erb"),
    require => File['/usr/local/bin/pg_util.rb'],
  }

  file {"/usr/local/bin/pg_fill.rb":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_fill.rb.erb"),
    require => File['/usr/local/bin/pg_util.rb'],
  }
  
  file {"/usr/local/bin/pg_load_tst_db.rb":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_load_tst_db.rb.erb"),
    require => File['/usr/local/bin/pg_util.rb'],
  }
  
  file {"/usr/local/bin/pg_poll.rb":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_poll.rb.erb"),
    require => File['/usr/local/bin/pg_util.rb'],
  }
  
  file {"/usr/local/bin/pg_util.rb":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_util.rb.erb"),
  }
  
  exec { "create_db_backup_dir_path":
    command => "mkdir -p `dirname ${db_backup_dir}`",
    path => '/usr/bin:/bin',
    unless => "[ -d `dirname ${db_backup_dir}` ]"
  }


  file { $db_backup_dir :
    ensure => directory,
    mode   => 0755,
    recurse => true,
    owner  =>  $::postgresql::params::user, group => $::postgresql::params::group,
    require     => Exec["create_db_backup_dir_path"],
  }
    
  cron { 'pg-backup':
      ensure  => $ensure,
      command => "$db_pg_dump_script",
      user    => 'root',
      hour    => 23,
      minute  => 15,
      require => File["$db_pg_dump_script", "$db_backup_dir"],
  }
}

