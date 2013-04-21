class includeAllThingsForA_Developer {
    include etckeeper
    include elexis::client
    include elexis::mysql_server
    include elexis::devel
    include elexis::awesome   
}

node 'devel' {
  include includeAllThingsForA_Developer
}
