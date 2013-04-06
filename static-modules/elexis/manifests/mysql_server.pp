# Here we define all needed stuff to bring up a complete
# mysql-server environment for Elexis

class elexis::mysql_server(
  $db_backup_dir      = hiera('::db::backup::dir', '/home/backup'),
  $db_backup_user     = hiera('::db::backup::user', 'elexis'),
  $db_backup_password = hiera('::db::backup::name', 'elexisTest'),
  $db_main_name       = hiera('::db::main::password', 'elexis'),
  $db_main_user       = hiera('::db::main::user', 'elexis'),
  $db_main_password   = hiera('::db::main::password', 'elexisTest'),
  $db_test_name       = hiera('::db::test::name', 'tst_db'),
  $db_my_dump_script  = hiera('::db::backup::dump_script', '/usr/local/bin/my_dump_elexis.rb')
){

}

class elexis::mysql_server inherits elexis::common {
  # With this file we ensure that the mysql root password is elexisTest!
  file { '/etc/mysql/debian.cnf':
    ensure => present,
    owner => 'root',
    mode => '640',
    source => 'puppet:///modules/elexis/debian.cnf',
  }

  # notify { "Granting for Elexis MySQL database": }
  package{  ['cups', 'cups-bsd']:
    ensure => present,
  }
  
  class { 'mysql::server':
  # package_name  => 'x', # hiera('mysql::server:package_name', 'mysql-server-5.5'),
  config_hash => { 'root_password' => hiera('mysql::server:root_password', 'elexisTest') } ,
  }

  mysql::db { "$db_main_name":
    user     => $db_main_user,
    password => $db_main_password,
    host     => 'localhost',
    ensure => present,
    charset => 'utf8',      
  }

  if $db_test_name {
    mysql::db { "$db_test_name":
      user     => $db_main_user,
      password => $db_main_password,
      host     => 'localhost',
      ensure => present,
      charset => 'utf8',      
    }
  }
  
  database_user{ 'vagrant@localhost':
    ensure        => present,
    password_hash => mysql_password(hiera('db::user:vagrant:password', 'vagrant')),
    require       => Class['mysql::server'],
  }

  database_user{ 'niklaus@localhost':
    ensure        => present,
    password_hash => mysql_password(hiera('db::user:giger:password', 'giger')),
    require       => Class['mysql::server'],
  }

  database_user{ 'arzt@localhost':
    ensure        => present,
    password_hash => mysql_password(hiera('db::user:arzt:password', 'aeskulap')),
    require       => Class['mysql::server'],
  }

  # TODO: Add grants for all Elexis users!
  database_grant { ['arzt@localhost/elexis', 'niklaus@localhost/elexis', 'vagrant@localhost/elexis']:
    privileges => ['all'] ,
  }
    
  exec { "create_mysql_dump_dir_path":
    command => "mkdir -p `dirname ${db_backup_dir}`",
    path => '/usr/bin:/bin',
    unless => "[ -d `dirname ${db_backup_dir}` ]"
  }

  $backupdir      = $db_backup_dir
  $backupuser     = $db_backup_user
  $backuppassword = $db_backup_password
  
  # see http://puppetlabs.com/blog/module-of-the-week-puppetlabs-mysql-mysql-management/
  # define test-deb (anonymized) # TODO: Vierte Priorität (Nice to have)
  class { 'mysql::backup':
    backupuser     => $db_backup_user,
    backuppassword => $backuppassword,
    backupdir      => $db_backup_dir,
  }

}
