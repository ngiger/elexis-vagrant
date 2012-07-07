
class includeAllThingsForA_Developer {
    notify { "node/elexisDev.pp includeAllThingsForA_Developer": }
    include etckeeper
    include elexis::client
    include elexis::server
    include elexis::devel
    include elexis::jenkins_2_1_7 # Jubula & jenkins config files
    include x2go::client
    include x2go::server
    include elexis::praxis_wiki
    include kde
}

class includeOnlyX2go {
    include x2go::server
    include x2go::client
}

node 'elexisDev' {
  include includeAllThingsForA_Developer
#  include includeOnlyX2go
}

node 'elexisDev32bit' {
  include includeAllThingsForA_Developer
#  include includeOnlyX2go
}


