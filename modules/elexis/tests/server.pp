notify { "test: elexis::server": }

# include elexis::server
include mysql
class { 'mysql::server':
  config_hash => { 'root_password' => 'elexisTest' }
}
include elexis::common

mysql::db { 'myElexis3':
  user     => 'elexis',
#  password_hash => mysql_password('elexisTest'),
#  password => 'elexisTest',
  password => mysql_password('elexisTest'),
  host     => 'localhost',
  grant    => ['all', 'elexis', 'elexis@localhost'],
  require => User['elexis'],
}


database_user{ 'vagrant@localhost':
  ensure        => present,
  password_hash => mysql_password('vagrant'),
  require       => Class['mysql::server'],
}


database_grant { 'elexis@localhost/myElexis1':
  privileges => ['all', 'elexis', '*@localhost'] ,
}

mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['all'],
}
database_grant{'test1@localhost/redmine':
  privileges => [update],
}
