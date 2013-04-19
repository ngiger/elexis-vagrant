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

class elexis::mysql_server inherits elexis::common {
  class { 'mysql::server': 
    config_hash => { 
      'root_password' => hiera('mysql::server:root_password', 'elexisTest'),
      # [mysqld]
      
    } ,
  }

  # With this file we ensure that the mysql root password is elexisTest!
  file { '/etc/mysql/debian.cnf':
    ensure => present,
    owner => 'root',
    mode => '640',
    source => 'puppet:///modules/elexis/debian.cnf',
  }

  notify{"m $mysql_main_db_name t $mysql_tst_db_name": }
  if (0 == 1) {
  mysql::db { "$mysql_main_db_name":
    user     => $mysql_main_db_user,
    password => $mysql_main_db_password,
    host     => 'localhost',
    ensure => present,
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
  
  database_user{ 'niklaus@localhost':
    ensure        => present,
    password_hash => mysql_password(hiera('db::user:giger:password', 'giger')),
    require       => Class['mysql::server'],
  }

  # TODO: Add grants for all Elexis users!
  database_grant { ['arzt@localhost/elexis', 'niklaus@localhost/elexis', 'vagrant@localhost/elexis']:
    privileges => ['all'] ,
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
    create 0640 root root
    nocompress
}
",
    owner => root,
    group => root,
    mode  => 0644,
  }

}
