
class includeAllThingsForA_Developer {
    notify { "node/elexisDev.pp includeAllThingsForA_Developer": }
    include etckeeper
    include elexis::client
    include elexis::server
    include elexis::devel

#   uncomment next line to add Jenkins & Jubula test for 2.1.7
#    elexis::jenkins_elexis{'2.1.7': } 

#   uncomment next three lines to add Juno
#    elexis::download_eclipse_version{'eclipse-rcp-juno':
#      baseURL => "${elexis::common::elexisFileServer}/eclipse",
#    }

    include x2go::client
    include x2go::server
    include elexis::praxis_wiki
    class {['kde']: stage => last; } # I want the interesting things to load first!
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
#  include includeAllThingsForA_Developer
#  include includeOnlyX2go
}
