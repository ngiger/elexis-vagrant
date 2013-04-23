class includeAllThingsForA_Developer {
    include etckeeper
    include elexis::admin
    include elexis::client
    include elexis::mysql_server
    include elexis::postgresql_server
    include elexis::devel
    include kde
    # include elexis::kde
    include elexis::elexis_bootstrap 
    x2go::server {"x2go-server": }    
    users { devel: }
    package{ "iceweasel": }
}

node 'devel' {
  include includeAllThingsForA_Developer
}
