# Here we define all needed stuff to bring up a complete
# server environment for Elexis

class elexis::server inherits elexis::common {

  include x2go::server
  package{  ['cups', 'cups-bsd']:
    ensure => present,
  }
  gem('gollum', 'install', nil, '--no-rdoc --no-ri') # install gollum wiki, TODO: Start server, set default to .textile  # TODO:
#  include mysql  # TODO:
#  include postgresql # TODO:
#  include h2sql # TODO:
 # define database # TODO:
 # define optional import
 # define backup # TODO:
 # define test (anonymized) # TODO:
}
