node "elexisDev" {
    notify { "node/elexisDev.pp": }
    include elexis::client
    include elexis::server
    include elexis::devel
    include elexis::jenkins_2_1_7 # Jubula & jenkins config files
    include x2go::client
    include x2go::server
    include elexis::praxis_wiki
    include kde
}

