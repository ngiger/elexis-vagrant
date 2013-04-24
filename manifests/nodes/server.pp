node "server" {

  notify{"Adding node server": }
  # These are the defaults for the node called server
  if hiera('elexis::praxis_wiki::ensure', true)         { include elexis::praxis_wiki }
  if hiera('elexis::postgresql_server::ensure', true)  { include elexis::postgresql_server }
  if hiera('elexis::mysql_server::ensure', true)       { include elexis::mysql_server }
  if hiera('elexis::mysql_server::ensure', true)       { include elexis::mysql_server }
  include cockpit
  # TODO: add backup postgres-server
  
  # Default values can be overridden by setting value in your private/config.yaml

  # This medical doctor uses KDE as his/her GUI
  if hiera('elexis::kde::ensure', true)       { include kde }
  
  # She/he uses the OpenSource Elexis client
  # elexis::client {"elexis-client": ensure => hiera('elexis::client::ensure', true) }

  # She/he has a local copy of the Elexis database on his system, which serves
  # as fallback if the main server is down
  # elexis::mysql_server{ "mysql-server:": ensure => hiera('elexis::mysql_server::ensure', true) }

  # When at home She/he uses x2go to connect to the practice server
  class { 'x2go': version => 'baikal', }
  x2go::client {"x2go-client": ensure => hiera('x2go::client::ensure', true) }
  x2go::server {"x2go-server": ensure => hiera('x2go::server::ensure', true) }

  # She/he wants to write letters and browse the internet
  # elexis::libreoffice {'loffice': ensure => hiera('elexis::libreoffice::ensure', true) }
  # elexis::firefox {'firefox': ensure => hiera('elexis::firefox::ensure', true) }

}
