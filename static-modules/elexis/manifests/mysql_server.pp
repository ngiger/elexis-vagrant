# Here we define all needed stuff to bring up a complete
# encoding: utf-8
# mysql-server environment for Elexis
# as per version 2.3 we can specify almost anything as parameter to the mysql::server class
# 
class elexis::mysql_server(
  $mysql_main_db_name      = hiera('elexis::mysql_main_db_name',     'elexis'),
  $mysql_main_db_user      = hiera('elexis::mysql_main_db_user',     ''),
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


class elexis::mysql_server inherits elexis::common {
  class { '::mysql::server': 
      root_password => hiera('mysql::server:root_password', 'elexisTest')
  }

  if $mysql_main_db_name {
    mysql_database { "$mysql_main_db_name":
      ensure  => 'present',
      charset => 'utf8',
      require => Class['mysql::server'],
    }
    
  }

  if $mysql_tst_db_name {
    mysql_database { "$mysql_tst_db_name":
      ensure  => 'present',
      charset => 'utf8',
      require => Class['mysql::server'],
    }
  }

  $lowercase_conf = '/etc/mysql/conf.d/lowercase.cnf'
  file {$lowercase_conf:
    ensure => present,
    content => "[mysqld]\nlower_case_table_names=1\n",
    owner => root,
    group => root,
    mode => 0644,
    require  => File['/etc/mysql/conf.d/'],
    before => File[$mysql::params::config_file],
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
    command => "mkdir -p $mysql_dump_dir $mysql_dump_dir/daily $mysql_dump_dir/monthly $mysql_dump_dir/yearly",
    path => '/usr/bin:/bin',
    creates => "$mysql_dump_dir/yearly"
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
    content => "
$mysql_dump_dir/monthly/${mysql_main_db_name}.dump.gz.1.1 {
    rotate 12
    olddir $mysql_dump_dir/yearly
    yearly
    missingok
    notifempty
    create 0640 root root
    nocompress
    size 10M
}

$mysql_dump_dir/daily/${mysql_main_db_name}.dump.gz.1 {
    rotate 12
    olddir $mysql_dump_dir/monthly
    monthly
    missingok
    notifempty
    create 0640 root root
    nocompress
    size 10M
}

$mysql_dump_dir/${mysql_main_db_name}.dump.gz {
    rotate 10
    olddir $mysql_dump_dir/daily
    daily
    missingok
    notifempty
    create 0640 root root
    nocompress
    size 10M
}
",
    owner => root,
    group => root,
    mode  => 0644,
  }

}
