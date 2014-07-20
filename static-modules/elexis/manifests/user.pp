# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# A utility class to easily add a user for Elexis
include elexis::common
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

define elexis::user(
  $username,
  $uid,
  $groups  = [$username],
  $comment  = '',
  $password = '',
  $ensure = present,
  $shell  = '/bin/sh',
) {
  ensure_packages(['ruby-shadow']) # needed for managing password
  $splitted = split($homes, ',')
  if (! $gid ) { $gid = $uid }
  if ("/home/$username" in $splitted)  {
    user{$username:
      managehome => true,
      ensure     => $ensure,
      groups     => $groups,
      shell      => $shell,
      uid        => $uid,
#      require    => Group[$groups],
    }
  } else {
    user{$username:
      managehome => true,
      ensure     => $ensure,
      groups     => $groups,
      comment    => $comment, # Motzt bei nicht US-ASCII Kommentaren wir Müller, aber nur wenn er nichts zu tun hat
      shell      => $shell,
      uid        => $uid,
#      require    => Group[$groups],
      password_min_age => 0, # force user to change it soon
    }
    if ("$ensure" != 'absent' ) { setpass { "$username": hash => "$password",  } }
  }
  group {$username: ensure => $ensure }
  if (!defined(Group['backup'])) {   group {'backup': ensure => present,  }  }

  if ("$ensure" != 'absent' and defined(Group[$username])) {
    exec{"/usr/sbin/adduser backup $username":
      require => [ Group[$username, 'backup']],
      unless => "/bin/grep ${username}: /etc/group  | /bin/grep backup",
    }
  }
} 

