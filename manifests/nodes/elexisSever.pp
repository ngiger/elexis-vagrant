class thingsForElexisServer {
    include etckeeper
    include elexis::client
    include elexis::server
    include x2go::server
    include elexis::praxis_wiki
    include elexis::postgresql_server # we want to be able to test with postgresql, too
}

node "elexisServer" {
    notify { "site.pp node elexisServer": }
    include thingsForElexisServer
}

node "elexisServer32bit" {
    notify { "site.pp node elexisServer": }
    include thingsForElexisServer
}

