# Here we define all needed stuff to bring up a complete
# mysql-server environment for Elexis

class elexis::mysql_server inherits elexis::common {

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
    # package_name  => 'x', # hiera('mysql::server:package_name', 'mysql-server-5.5'),
    config_hash => { 'root_password' => hiera('mysql::server:root_password', 'elexisTest') } ,
    }

    $mysql_db_elexis_name     = hiera('mysql::db:elexis:name', 'elexis')
    $mysql_db_elexis_user      = hiera('mysql::db:elexis:user', 'elexis')
    $mysql_db_elexis_password = hiera('mysql::db:elexis:password', 'elexis')
    mysql::db { "$mysql_db_elexis_name":
      user     => $mysql_db_elexis_user,
      password => $mysql_db_elexis_password,
      host     => 'localhost',
      ensure => present,
      charset => 'utf8',      
    }

  $mysql_db_tst_db_name      = hiera('mysql:db:elexis:name', 'tst_db')
  if $mysql_db_tst_db_name {
    mysql::db { "$mysql_db_tst_db_name":
      user     => $mysql_db_elexis_user,
      password => $mysql_db_elexis_password,
      host     => 'localhost',
      ensure => present,
      charset => 'utf8',      
    }
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
    
  $backupdir      = hiera('mysql::db:backup:dir',      '/home/backup')
  $backupuser     = hiera('mysql::db:backup:user',     'elexis')
  $backuppassword = hiera('mysql::db:backup:password', 'elexisTest')
  
  # see http://puppetlabs.com/blog/module-of-the-week-puppetlabs-mysql-mysql-management/
  # define test-deb (anonymized) # TODO: Vierte Priorität (Nice to have)
  class { 'mysql::backup':
    backupuser     => $backupuser,
    backuppassword => $backuppassword,
    backupdir      => $backupdir,
  }

}
