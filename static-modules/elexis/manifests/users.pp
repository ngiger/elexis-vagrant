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
    value     => "$hash:13572:0:99999:7:::",
    delimiter => ':'
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
  # notify{"system_user: $username uid $uid g $groups pw $password comment $comment": }
  setpass { "$username": hash => "$password", }    
  user{$username:
    managehome => true,
    ensure     => $ensure,
    groups     => $groups,
    comment    => $comment, # Motzt bei nicht US-ASCII Kommentaren wir Müller, aber nur wenn er nichts zu tun hat
    shell      => $shell,
    uid        => $uid,
  }
}

define system_users(
) {
  ensure_resource('system_user', $title[name], 
    { 
      username   => $title['name'],
      password   => $title['password'],
      uid        => $title['uid'],
      groups     => $title['groups'],
      comment    => $title['comment'],
      shell      => $title['shell'],
      ensure     => $title['ensure'],
    }    
  )
}
