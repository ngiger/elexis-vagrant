# encoding: utf-8
node "server" {
  # notify{"Adding node server": }
  file{'/etc/system_role': content => "server\n" }
  # These are the defaults for the node called server
  if hiera('elexis::praxis_wiki::ensure', true)        { include elexis::praxis_wiki }
  if hiera('elexis::postgresql_server::ensure', true)  { include elexis::postgresql_server }
  if hiera('elexis::mysql_server::ensure', true)       { include elexis::mysql_server }
  if hiera('elexis::cockpit::ensure', true)            { include cockpit::service}
  
    # Default values can be overridden by setting value in your private/config.yaml

  # This medical doctor uses KDE as his/her GUI
  if hiera('kde::server::ensure', true)       { include kde }

  # When at home She/he uses x2go to connect to the practice server
  if hiera('x2go::ensure', true)       { 
      include kde 
      x2go::client {"x2go-client": ensure => true }
      x2go::server {"x2go-server": ensure => true }
  }
  if hiera('samba::ensure', true) {  include elexis::samba  }
}
