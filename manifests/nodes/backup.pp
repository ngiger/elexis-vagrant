node "backup" {

    if hiera('x2go::server:included', true)               { include x2go::server }
    if hiera('elexis::server:included', true)             { include elexis::server }
    if hiera('elexis::praxis_wiki:included', true)        { include elexis::praxis_wiki }
    if hiera('elexis::postgresql_server:included', true)  { include elexis::postgresql_server }
    if hiera('elexis::server:included', true)             { include elexis::server }

 }
