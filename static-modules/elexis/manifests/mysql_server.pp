# Here we define all needed stuff to bring up a complete
# mysql-server environment for Elexis

class elexis::mysql_server(
  $mysql_backup_dir        = hiera('elexis::mysql_server::mysql_backup_dir',       '/home/backups/mysql'),
  $mysql_dump_dir          = hiera('elexis::mysql_server::mysql_dump_dir',         '/home/backup-mysql'),
  $mysql_main_db_name      = hiera('elexis::mysql_server::mysql_main_db_name',     'elexis'),
  $mysql_main_db_user      = hiera('elexis::mysql_server::mysql_main_db_user',     'elexis'),
  # puppet apply --execute 'notify { "test": message => mysql_password("elexis", "elexisTest") }' --modulepath /vagrant/modules/
  $mysql_main_db_password  = hiera('elexis::mysql_server::mysql_main_db_password', 'elexisTest'),
  $mysql_tst_db_name       = hiera('elexis::mysql_server::mysql_tst_db_name',      'tst_db'),

){

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
    $hash2use = mysql_password("$db_password")
    # notify{"$title: grant uses password $db_password hash is $hash2use": }
  }
  
  if !defined(Database_user["$db_user"]) {
    database_user{"$db_user":
      password_hash => $hash2use,
    }
  }  
  
  if !defined(Database["$db_name"]) {
    database{"$db_name":
      ensure => present,
      charset => 'de_CH.UTF-8',
    }
  }
  
  $grant_id = "${db_user}_on_${db_name}"
  # notify{"$title: grantid $grant_id": }
  if !defined(Database_grant["$grant_id"]) {
    database_grant {$grant_id :
      privileges => [$db_privileges] ,
      # Or specify individual privileges with columns from the mysql.db table:
      # privileges => ['Select_priv', 'Insert_priv', 'Update_priv', 'Delete_priv']
      require => [
        Database_user["$db_user"],
        Database["$db_name"],
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

class elexis::mysql_server inherits elexis::common {
  class { 'mysql::server': 
    config_hash => { 
      'root_password' => hiera('mysql::server:root_password', 'elexisTest'),
      # [mysqld]      
    } ,
  }

  $dbs= hiera('mysql_dbs', 'cbs')
  elexis::dbusers{$dbs: }

  database_user{"elexis@localhost":
    password_hash => mysql_password('elexisTest'),
  }

  database_user{'reader@%':
    password_hash => mysql_password('elexisTest'),
  }

  notify{"m $mysql_main_db_name t $mysql_tst_db_name": }
  if $mysql_main_db_name {
    database { "$mysql_main_db_name":
      ensure  => 'present',
      charset => 'utf8',
    }
  }

  if $mysql_tst_db_name {
    database { "$mysql_tst_db_name":
      ensure  => 'present',
      charset => 'utf8',
    }
  }

  file {'/etc/mysql/conf.d/lowercase.conf':
    ensure => present,
    content => "[mysqld]\nlower_case_table_names = 1\n",
    owner => root,
    group => root,
    mode => 0644,
  }
  
  $db_mysql_dump_script = "/usr/local/bin/mysql_dump_elexis.rb"
  file {$db_mysql_dump_script:
    ensure => present,
    mode   => 0755,
    content => template("elexis/mysql_dump_elexis.rb.erb"),
#    require => File['/usr/local/bin/pg_util.rb'],
  }

  $db_mysql_load_script = "/usr/local/bin/mysql_load_tst_db.rb"
  file {$db_mysql_load_script:
    ensure => present,
    mode   => 0755,
    content => template("elexis/mysql_load_tst_db.rb.erb"),
#    require => File['/usr/local/bin/pg_util.rb'],
  }

  exec { "$mysql_backup_dir":
    command => "mkdir -p $mysql_backup_dir",
    path => '/usr/bin:/bin',
    creates => "$mysql_backup_dir"
  }

  file { $mysql_backup_dir :
    ensure => directory,
    mode   => 0755,
    recurse => true,
    owner  =>  $::mysql::params::user, group => $::mysql::params::group,
    require     => Exec["$mysql_backup_dir"],
  }
    
  exec { "$mysql_dump_dir":
    command => "mkdir -p ${mysql_dump_dir}",
    path => '/usr/bin:/bin',
    creates => "$mysql_dump_dir"
  }

  file { $mysql_dump_dir :
    ensure => directory,
    mode   => 0755,
    recurse => true,
    owner  =>  $::mysql::params::user, group => $::mysql::params::group,
    require     => Exec["$mysql_dump_dir"],
  }
    
  cron { 'mysql-elexis-backup':
      ensure  => $ensure,
      command => "$db_mysql_dump_script",
      user    => 'root',
      hour    => 23,
      minute  => 15,
      require => [
        File["$db_mysql_dump_script", "$mysql_backup_dir"],
        Exec["$mysql_backup_dir", "$mysql_dump_dir"],
      ]
      
  }

  file {'/etc/logrotate.d/mysql_elexis_dump':
    ensure => present,
    content => "\n${$mysql_dump_dir}/elexis.dump.gz {
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
