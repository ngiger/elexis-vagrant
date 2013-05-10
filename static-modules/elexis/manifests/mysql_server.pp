# Here we define all needed stuff to bring up a complete
# encoding: utf-8
# mysql-server environment for Elexis

class elexis::mysql_server(
  $mysql_main_db_name      = hiera('elexis::mysql_main_db_name',     'elexis'),
  $mysql_main_db_user      = hiera('elexis::mysql_main_db_user',     'elexis'),
  $mysql_main_db_password  = hiera('elexis::mysql_main_db_password', 'elexisTest'),
  $mysql_tst_db_name       = hiera('elexis::mysql_tst_db_name',      'test'),
  $mysql_dump_dir          = hiera('elexis::mysql_dump_dir',         '/opt/backup/mysql/dumps'),
  $mysql_backup_dir        = hiera('elexis::mysql_backup_dir',       '/opt/backup/mysql/backups'),
  $mysql_group             = 'mysql',
  $mysql_user              = 'mysql',
) {
  include elexis::admin
  ensure_resource('user', 'mysql', { ensure => present})
  $mysql_dump_script       = '/usr/local/bin/mysql_dump_elexis.rb'
  $mysql_load_main_script  = '/usr/local/bin/mysql_load_main_db.rb'
  $mysql_load_test_script  = '/usr/local/bin/mysql_load_test_db.rb'
}

define elexis::mysql_dbuser(
  $db_user,
  $db_name,
  $db_privileges  = 'ALL',
  $db_pw_hash  = '',
  $db_password = '',
) {
  include mysql
  
  # notify{"$title: grant $db_privileges on $db_name to $db_user pw $db_password/$db_pw_hash": }
  if ($db_pw_hash != '') {
    # notify{"$title: $db_user grant $db_privileges has $db_pw_hash": }
    $hash2use = $db_pw_hash
  } else 
  {
    if ("$db_password" == '') {
      $hash2use = ''
      # notify{"$title:  empty hash":}
    } else
    {
      $hash2use = mysql_password("$db_password")
      # notify{"$title:  $db_user grant $db_privileges uses password $db_password hash is $hash2use": }
    }
  }
  
  # Ensure mysql is setup before running database/user creation
  Package[$mysql::params::server_package_name] -> Database       <| |> 
  Package[$mysql::params::client_package_name] -> Database       <| |> 
  Package[$mysql::params::server_package_name] -> Database_user  <| |> 
  Package[$mysql::params::client_package_name] -> Database_user  <| |> 



  if ("$hash2use" != '') {
    ensure_resource(database_user, "$db_user",
      {
        password_hash => $hash2use,
        require => Class['mysql::config'],
      }
    )
  }
  
  if !defined(Database["$db_name"]) {
    database{"$db_name":
      ensure => present,
      charset => 'de_CH.UTF-8',
    }
  }
  
  $grant_id = "${db_user}"
  $msg = "grantid $grant_id mit hash $hash2use"
  # if !defined(Notify[$msg]) { notify{"$msg": }  }
  if !defined(Database_grant["$grant_id"]) {
    database_grant {$grant_id :
      privileges => [$db_privileges] ,
      # Or specify individual privileges with columns from the mysql.db table:
      # privileges => ['Select_priv', 'Insert_priv', 'Update_priv', 'Delete_priv']
      require => [
        Database["$db_name"],
        Class['mysql::config'],
      ]
    }
  }
  

}

define elexis::mysql_dbusers(
) {
  $db_name =  $title[db_name]
  $db_pw_hash =  $title[db_pw_hash]
  $db_user =  $title[db_user]
  $db_password =  $title[db_password]
  $db_privileges = $title[db_privileges]
  $myName = "${db_name}_${db_user}"
  # notify{"mysql_dbusers $myName mit $db_name priv $db_privileges": }
  elexis::mysql_dbuser{"$myName":
    db_name => "$db_name",
    db_user => "$db_user",
    db_password => "$db_password",
    db_pw_hash => "$db_pw_hash",
    db_privileges => "$db_privileges",
  }
  database_grant {"$myName" :
    privileges => [$db_privileges] ,
    require => [
      Database["$db_name"],
      Class['mysql::config'],
    ]
  }
}

class elexis::mysql_server inherits elexis::common {
  class { 'mysql::server': 
    config_hash => { 
      'root_password' => hiera('mysql::server:root_password', 'elexisTest'),
      'bind_address'  => hiera('mysql::server:bind_address','0.0.0.0'),       # listen on all network interfaces
    } ,
  }

  $dbs         = hiera('mysql_dbs', '')
  # notify{"nmysql dbs are $dbs": }
  if ($dbs != '') {  elexis::mysql_dbusers{$dbs: } }
  $mainUser = hiera("elexis::db_user", 'elexis')
  $mainPw   = hiera("elexis::db_password", 'elexisTest')

  # notify{"m $mysql_main_db_name t $mysql_tst_db_name": }
  if $mysql_main_db_name {
    database { "$mysql_main_db_name":
      ensure  => 'present',
      charset => 'utf8',
      require => Class['mysql::server'],
    }
    
  }

  if $mysql_tst_db_name {
    database { "$mysql_tst_db_name":
      ensure  => 'present',
      charset => 'utf8',
      require => Class['mysql::server'],
    }
  }

  file {'/etc/mysql/conf.d/lowercase.cnf':
    ensure => present,
    content => "[mysqld]\nlower_case_table_names=1\n",
    owner => root,
    group => root,
    mode => 0644,
  }
  
  file {"$mysql_dump_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/mysql_dump_elexis.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
  }

  file {"${mysql_load_main_script}":
    ensure => present,
    mode   => 0755,
    content => template("elexis/mysql_load_main_db.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
  }
  
  file {"$mysql_load_test_script":
    ensure => present,
    mode   => 0755,
    content => template("elexis/mysql_load_tst_db.rb.erb"),
    require => File[$elexis::admin::pg_util_rb],
  }

  exec { "$mysql_backup_dir":
    command => "mkdir -p $mysql_backup_dir",
    path => '/usr/bin:/bin',
    creates => "$mysql_backup_dir"
  }
  
  if (0==1) { # we don't use the backup class of mysql as it creates the backupdir as root:root
    class { 'mysql::backup':
      backupuser     =>  'backup', # hiera("elexis::db_user", 'elexis'),
      backuppassword =>  hiera("elexis::db_password", 'elexisTest'),
      backupdir      =>  $mysql_backup_dir,
    }
  }

  exec { "$mysql_dump_dir":
    command => "mkdir -p ${mysql_dump_dir}",
    path => '/usr/bin:/bin',
    creates => "$mysql_dump_dir"
  }

  file { [ $mysql_dump_dir, $mysql_backup_dir]: #  $mysql_backup_dir not needed as already declared in modules/mysql/manifests/backup.pp:70
    ensure => directory,
    mode   => 0775,
    recurse => true,
    owner  =>  $mysql_user, group => $mysql_group,
    require     => Exec["$mysql_dump_dir"],
  }
    
  cron { 'mysql-elexis-backup':
      ensure  => $ensure,
      command => "$mysql_dump_script",
      user    => 'root',
      hour    => 18,
      minute  => 30,
      require => [
        File["$mysql_dump_script", "$mysql_backup_dir"],
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
