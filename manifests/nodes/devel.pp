class includeAllThingsForA_Developer {
    include etckeeper
    include elexis::admin
    include elexis::client
    include elexis::mysql_server
    include elexis::postgresql_server
    include elexis::devel
    include kde
    include elexis::elexis_bootstrap 
    if hiera('x2go::ensure', true)       { 
      package{ "iceweasel": }
      x2go::server {"x2go-server": }
    }
    $users_devel        = hiera('users_devel')
    if ($users_devel) { elexis::users  {"developement users": user_definition       => $users_devel} }
}

node 'devel' {
  include includeAllThingsForA_Developer
}
