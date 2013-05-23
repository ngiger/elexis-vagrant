# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# A utility class to easily add users for Elexis
define elexis::users(
  $user_definition
) {
  
  # notify{"elexis::users: $user_definition":}
  elexis_add_users{$user_definition: }
}

define elexis_add_users(
) {
  include elexis::common 
  $elexis_main        = hiera('users_elexis_main')
  $main_user          = $elexis_main['name']

  $username = $title['name']
  $expire_log = "/var/log/expire_user_$username"
  $comment    = $title['comment']
  $ensure   = $title['ensure']
  # comment Motzt bei nicht US-ASCII Kommentaren wir Müller, aber nur wenn
  # der kommentar schon definiert wurd
  elexis::user{$username: 
    username   => $username,
    password   => $title['password'],
    uid        => $title['uid'],
    groups     => $title['groups'],
    comment    => $comment,
    shell      => $title['shell'],
    ensure     => $title['ensure'],
    require    => Elexis::User[$main_user], # elexis must be created first!
  }    
}
