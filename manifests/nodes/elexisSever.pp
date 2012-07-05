node "elexisServer" {
    notify { "site.pp node elexisServer": }
    include elexis::client
    include elexis::server
    include x2go::server
    include elexis::praxis_wiki

}

