node "backup" {

    if hiera('x2go::server::ensure', true)               { x2go::server {"x2go-server": }}
    if hiera('elexis::mysql_server::ensure', true)       { include elexis::mysql_server }
    if hiera('elexis::praxis_wiki::ensure', true)        { include elexis::praxis_wiki }
    if hiera('elexis::postgresql_server::ensure', false)  { include elexis::postgresql_server }

 }
