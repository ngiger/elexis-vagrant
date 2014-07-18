# encoding: utf-8
node "net_server" {
  # notify{"Adding node server": }
  file{'/etc/system_role': content => "server\n" }
  # These are the defaults for the node called server
#  if hiera('elexis::praxis_wiki::ensure', true)        { include elexis::praxis_wiki }
  if hiera('elexis::postgresql_server::ensure', true)   { include elexis::postgresql_server }
#  if hiera('elexis::mysql_server::ensure', true)        { include elexis::mysql_server }
#  if hiera('elexis::cockpit::ensure', false)             { include cockpit::service}
  if hiera('luks_backup::ensure', true)                 { include luks_backup }
  if hiera('x2go::client::ensure', true)                { x2go::client {"x2go-client": ensure => true } }
  if hiera('dnsmasq::ensure', false)                    { include dnsmasq }
  if hiera('samba::ensure', true)                       { include elexis::samba  }
}
