node "elexisServer" {
    notify { "site.pp node elexisServer": }
    include elexis::client
    include elexis::devel
    include elexis::server
    include elexis::jenkins_2_1_7
    include x2go::server
    include elexis::praxis_wiki

}

