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
  $pg_backup_dir        = hiera('elexis::postgresql_server::pg_backup_dir',       '/home/backups/postgresql'),
  $pg_dump_dir          = hiera('elexis::postgresql_server::pg_dump_dir',         '/home/dumps/postgresql'),
  $pg_main_db_name      = hiera('elexis::postgresql_server::pg_main_db_name',     'elexis'),
  $pg_main_db_user      = hiera('elexis::postgresql_server::pg_main_db_user',     'elexis'),
  # puppet apply --execute 'notify { "test": message => postgresql_password("elexis", "elexisTest") }' --modulepath /vagrant/modules/
  $pg_main_db_password  = hiera('elexis::postgresql_server::pg_main_db_password', 'elexisTest'),
  $pg_tst_db_name       = hiera('elexis::postgresql_server::pg_tst_db_name',      'tst_db'),
){
  include concat::setup

}

define elexis::db_user(
  $db_user,
  $db_name,
  $db_privileges  = 'ALL',
  $db_pw_hash  = '',
  $db_password = '',
) {
  
  # notify{"$title: grant $db_privileges on $db_name to $db_user pw $db_password/$db_pw_hash": }
  if ($db_pw_hash != '') {
    # notify{"$title: grant has $db_pw_hash": }
    $hash2use = $db_pw_hash
  } else {
    $hash2use = postgresql_password("$db_user", "$db_password")
    # notify{"$title: grant uses password $db_password hash is $hash2use": }
  }
  
  if !defined(Postgresql::Database_user["$db_user"]) {
    postgresql::database_user{"$db_user":
      password_hash => postgresql_password("$db_user", "$hash2use"),
    }
  }  
  
  $grant_id = "GRANT $db_user - $db_privileges - $db_name"  
  if !defined(Postgresql::Database_grant["$grant_id"]) {
    postgresql::database_grant{"$grant_id":
      privilege   => "$db_privileges",
      db          => "$db_name",
      role        => "$db_user",
      require => [
        Postgresql::Database_user["$db_user"],
        Postgresql::Db["$db_name"],
      ]
    }
  }
}

define elexis::dbusers(
) {
  $db_name =  $title[db_name]
  $db_pw_hash =  $title[db_pw_hash]
  $db_user =  $title[db_user]
  $db_password =  $title[db_password]
  $db_privileges = $title[db_privileges]
  $myName = "${db_name}_${db_user}"
  elexis::db_user{$myName:
    db_name => "$db_name",
    db_user => "$db_user",
    db_password => "$db_password",
    db_pw_hash => "$db_pw_hash",
    db_privileges => "$db_privileges",
  }
}

class elexis::postgresql_server inherits elexis::common {
  include postgresql::params
  $dbs= hiera('dbs', 'cbs')
  elexis::dbusers{$dbs:   
  }
    
  file  { "${pg_backup_dir}/wal/":
    ensure => directory,
    owner  => 'postgres',
    mode   => 0755,
  }
  package { 'postgresql-contrib':
    ensure => present,
    }
  $config_hash = hiera('pg::config_hash', '')
  $conf_dir    = $postgresql::params::confdir
  class {'postgresql::server':
    config_hash => $config_hash,
    require => [ File["$conf_dir/postgresql_puppet_extras.conf"], Package['postgresql-contrib'] ],
  }
  
  $puppet_extras = hiera('pg::puppet_extras', '#no variable pg::puppet_extras defined!')
  file {"$conf_dir/postgresql_puppet_extras.conf":
    content => template("elexis/postgresql_puppet_extras.conf.erb"),
    owner  =>  'postgres', group => 'postgres',
    mode   => 0644, 
  }
     
  if $pg_main_db_name {
    postgresql::db { "$pg_main_db_name":
      locale => 'de_CH.UTF-8',      
      user    => $pg_main_db_user,
      password => $db_main_pw_hash,
    }
  }
  
  if $pg_tst_db_name {
    postgresql::db { "$pg_tst_db_name":
      locale => 'de_CH.UTF-8',      
      user    => $pg_main_db_user,
      password => $db_main_pw_hash,
    }
  }

  $db_pg_dump_script = "/usr/local/bin/pg_dump_elexis.rb"
  file {$db_pg_dump_script:
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
  
  exec { "$pg_backup_dir":
    command => "mkdir -p $pg_backup_dir",
    path => '/usr/bin:/bin',
    creates => "$pg_backup_dir"
  }

  file { $pg_backup_dir :
    ensure => directory,
    mode   => 0755,
    recurse => true,
    owner  =>  $::postgresql::params::user, group => $::postgresql::params::group,
    require     => Exec["$pg_backup_dir"],
  }
    
  exec { "$pg_dump_dir":
    command => "mkdir -p ${pg_dump_dir}",
    path => '/usr/bin:/bin',
    creates => "$pg_dump_dir"
  }

  file { $pg_dump_dir :
    ensure => directory,
    mode   => 0755,
    recurse => true,
    owner  =>  $::postgresql::params::user, group => $::postgresql::params::group,
    require     => Exec["$pg_dump_dir"],
  }
    
  cron { 'pg-backup':
      ensure  => $ensure,
      command => "$db_pg_dump_script",
      user    => 'root',
      hour    => 23,
      minute  => 15,
      require => [
        File["$db_pg_dump_script", "$pg_backup_dir"],
        Exec["$pg_backup_dir", "$pg_dump_dir"],
      ]
      
  }

  file {'/etc/logrotate.d/pg_elexis_dump':
    ensure => present,
    content => "\n${$pg_dump_dir}/elexis.dump.gz {
    rotate 10
    daily
    missingok
    notifempty
    dateext
    create 0640 root root
    nocompress
}
",
    owner => root,
    group => root,
    mode  => 0644,
  }


}

