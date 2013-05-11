# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# A utility class to easily add users for Elexis
define elexis::users(
  $user_definition
) {
  
  # notify{"elexis::users: $user_definition":}
  system_users{$user_definition: }
}

define ensure_key_value($file, $key, $value, $delimiter = " ") {
    # passing the values via the environment simplifies quoting.
    Exec {
        environment => [ "P_KEY=$key",
                        "P_VALUE=$value",
                        "P_DELIM=$delimiter",
                        "P_FILE=$file" ],
        path => "/bin:/usr/bin",
    }

    # append line if "$key" not in "$file"
    exec { "append-$name":
        command => 'printf "%s\n" "$P_KEY$P_DELIM$P_VALUE" >> "$P_FILE"',
        unless  => 'grep -Pq -- "^\Q$P_KEY\E\s*\Q$P_DELIM\E" "$P_FILE"',
    }

    # update it if it already exists
    exec { "update-$name":
        command => 'perl -pi -e \'s{^\Q$ENV{P_KEY}\E\s*\Q$ENV{P_DELIM}\E.*}{$ENV{P_KEY}$ENV{P_DELIM}$ENV{P_VALUE}}g\' --  "$P_FILE"',
        unless  => 'grep -Pq -- "^\Q$P_KEY\E\s*\Q$P_DELIM\E\s*\Q$P_VALUE\E$" "$P_FILE"',
    }
}

define setpass($hash, $file='/etc/shadow') {
  ensure_key_value{ "set_pass_$name":
    file      => $file,
    key       => $name,
    value     => "$hash:0:0:99999:7:::",
    delimiter => ':',
    require   => User[$name],
    }
}

define system_user(
  $username,
  $uid,
  $groups  = '',
  $comment  = '',
  $password = '',
  $ensure = present,
  $shell  = '/bin/sh',
) {
  
  ensure_packages(['ruby-shadow']) # needed for managing password
  $splitted = split($homes, ',')
  
  if ("/home/$username" in $splitted)  {
    user{$username:
      managehome => true,
      ensure     => $ensure,
      groups     => $groups,
      shell      => $shell,
      uid        => $uid,
    }
  } else {
    user{$username:
      managehome => true,
      ensure     => $ensure,
      groups     => $groups,
      comment    => $comment, # Motzt bei nicht US-ASCII Kommentaren wir Müller, aber nur wenn er nichts zu tun hat
      shell      => $shell,
      uid        => $uid,
      password_min_age => 0, # force user to change it soon
    } 
    if ("$ensure" != 'absent' ) { setpass { "$username": hash => "$password",  } }
  }    
} 

define system_users(
) {

  $username = $title['name']
  $expire_log = "/var/log/expire_user_$username"
  $comment    = $title['comment']
  $ensure   = $title['ensure']
  # comment Motzt bei nicht US-ASCII Kommentaren wir Müller, aber nur wenn
  # der kommentar schon definiert wurd
  system_user{$username: 
    username   => $username,
    password   => $title['password'],
    uid        => $title['uid'],
    groups     => $title['groups'],
    comment    => $comment,
    shell      => $title['shell'],
    ensure     => $title['ensure'],
  }    
}
