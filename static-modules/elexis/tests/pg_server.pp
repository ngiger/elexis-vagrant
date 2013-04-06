notify { "test: elexis::postgresql_server": }
include concat::setup
include elexis::pg_server
include elexis::pg_users