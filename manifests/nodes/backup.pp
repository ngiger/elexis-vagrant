node "backup" {
  file{'/etc/system_role': content => "backup\n"  }

  x2go::client {"x2go-client": ensure => hiera('x2go::client::ensure', true) }
  x2go::server {"x2go-server": ensure => hiera('x2go::server::ensure', true) }
  if hiera('elexis::mysql_server::ensure', true)       { include elexis::mysql_server }
  if hiera('elexis::praxis_wiki::ensure', true)        { include elexis::praxis_wiki }
  if hiera('elexis::postgresql_server::ensure', false)  { include elexis::postgresql_server }
  if hiera('samba::ensure', true) {  include elexis::samba  }

}
