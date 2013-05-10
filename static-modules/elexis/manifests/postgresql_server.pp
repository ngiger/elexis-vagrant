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
  $pg_main_db_name      = hiera('elexis::pg_main_db_name',     'elexis'),
  $pg_main_db_user      = hiera('elexis::pg_main_db_user',     'elexis'),
  $pg_main_db_password  = hiera('elexis::pg_main_db_password', 'elexisTest'),
#  $pg_main_db_password  = hiera('elexis::pg_main_pw_hash',     'elexisTest'),
  $pg_test_db_name      = hiera('elexis::pg_test_db_name',     'test'),
  $pg_dump_dir          = hiera('elexis::pg_dump_dir',         '/opt/backup/pg/dumps'),
  $pg_backup_dir        = hiera('elexis::pg_backup_dir',       '/opt/backup/pg/backups'),
  $pg_group             = 'postgres',
  $pg_user              = 'postgres',
){
  $pg_dump_script       = '/usr/local/bin/pg_dump_elexis.rb'
  $pg_load_main_script  = '/usr/local/bin/pg_load_main_db.rb'
  $pg_load_test_script  = '/usr/local/bin/pg_load_test_db.rb'
  $pg_util_script       = '/usr/local/bin/pg_util.rb'
  $pg_poll_script       = '/usr/local/bin/pg_poll.rb'
  $pg_fill_script       = '/usr/local/bin/pg_fill.rb'
  $pg_archive_wal_script= '/usr/local/bin/pg_archive_wal.sh'
}

define elexis::pg_dbuser(
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
  
  if !defined(Postgresql::Role["$db_user"]) {
    postgresql::role{"$db_user":
      login => true,
      password_hash => $hash2use,
      require => Service[postgresqld],
    }
  }  
  
  if !defined(Postgresql::Database["$db_name"]) {
    postgresql::database{"$db_name":
    }
  }
  
  $grant_id = "GRANT $db_user - $db_privileges - $db_name"  
  if !defined(Postgresql::Database_grant["$grant_id"]) {
    postgresql::database_grant{"$grant_id":
      privilege   => "$db_privileges",
      db          => "$db_name",
      role        => "$db_user",
      require => [
        Postgresql::Role["$db_user"],
        Postgresql::Database["$db_name"],
        Service[postgresqld],
      ]
    }
  }
}

define elexis::pg_dbusers(
) {
  include elexis::postgresql_server
  $db_name =  $title[db_name]
  $db_pw_hash =  $title[db_pw_hash]
  $db_user =  $title[db_user]
  $db_password =  $title[db_password]
  $db_privileges = $title[db_privileges]
  $myName = "${db_name}_${db_user}"
  elexis::pg_dbuser{$myName:
    db_name => "$db_name",
    db_user => "$db_user",
    db_password => "$db_password",
    db_pw_hash => "$db_pw_hash",
    db_privileges => "$db_privileges",
  }
}

class elexis::postgresql_server inherits elexis::common {
  include concat::setup
  include postgresql
  include postgresql::client
  include elexis::admin
  
  user{'postgres': 
    require => Package[$postgresql::params::client_package_name],
  }
  group{'postgres':
    require => Package[$postgresql::params::client_package_name],
  }
  
  $dbs= hiera('pg_dbs', 'cbs')
  elexis::pg_dbusers{$dbs:   
  }
    
  file  { "${pg_backup_dir}/wal/":
    ensure => directory,
    owner  => $pg_user,
    group  => $pg_group,
    mode   => 0775,
  }
  package { 'postgresql-contrib':
    ensure => present,
    }

  # now comes the whole setup for online backup on server and backup
  if ("$hostname"== "server") {
    $backup_partner       = "backup"
    $backup_dir           = "/opt/backups_from_backup"
    $reverse_backup_dir   = "/opt/backups_from_server"
  } else { if ("$hostname"== "backup") {
    $backup_partner       = "server"
    $backup_dir           = "/opt/backups_from_server"  
    $reverse_backup_dir   = "/opt/backups_from_backup"
  } else  {
    notify{"host $hostname is neither backup nor server": }
  } }  
  # notify{"pg: wal $backup_dir $reverse_backup_dir": }
  if ("$backup_dir" != "")  {
    # notify{"pg: Creating $backup_dir $reverse_backup_dir": }
    sshd_config { "PermitEmptyPasswords":
      ensure    => present,
      condition => "Host $backup_partner",
      value     => "yes",
    }
    
    file { "$backup_dir":
      ensure => directory,
    }
    
    file { "$reverse_backup_dir":
      ensure => directory,
    }
    
    file { "$backup_dir/wal":
      ensure => directory,
      require => File[$backup_dir],
    }
    
  }
  file {"$pg_archive_wal_script":
    ensure => present,
    source => 'puppet:///modules/elexis/pg_archive_wal.sh',
    owner  => 'postgres',
    group  => 'postgres',
    mode   => 0744,
  }
    
  $config_hash = hiera('pg::config_hash', '')
  $conf_dir    = $postgresql::params::confdir
  $archive_timeout = hiera('pg::pg_archive_timeout', '600') # by default every 10 minutes = 600 seconds
  # template("elexis/postgresql_puppet_extras.conf.erb"),
  file {"$conf_dir/postgresql_puppet_extras.conf":
    content => "# managed by puppet. see elexis/manifests/postgresql_server.pp
archive_command = '/usr/bin/test ! -f ${backup_dir}/wal/%f && /bin/cp %p ${reverse_backup_dir}/%f < /dev/null'
archive_timeout = ${archive_timeout}
autovacuum =      on
",
  }
  
  
  class {'postgresql::server':
    config_hash => $config_hash,
    require => [ File["$conf_dir/postgresql_puppet_extras.conf"], Package['postgresql-contrib'] ],
  }
  
  postgresql::pg_hba_rule { "allow application network to access all database from localhost":
    description => "Open up postgresql for access from localhost",
    type => 'host',
    database => 'all',
    user => 'all',
    address => '127.0.0.1/32',
    auth_method => 'md5',
  }
  
  file {"$pg_dump_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_dump_elexis.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
  }

  file {"$pg_fill_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_fill.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
  }
  
  file {"$pg_load_test_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_load_tst_db.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
  }
  
  file {"$pg_load_main_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_load_main_db.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
  }
  
  file {"$pg_poll_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_poll.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
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
      command => "$pg_dump_script",
      user    => 'root',
      hour    => 23,
      minute  => 15,
      require => [
        File["$pg_dump_script", "$pg_backup_dir"],
        Exec["$pg_backup_dir", "$pg_dump_dir"],
      ]
      
  }

  file {'/etc/cron.weekly/pg_load_test_script.rb':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode  => 0755,
    require => File["$pg_load_test_script"],
    content => "#!/bin/sh
test -x ${pg_load_test_script} || exit 0
${pg_load_test_script}
"
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

