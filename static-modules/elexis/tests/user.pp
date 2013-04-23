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


user { 'elexisDemoUser':
  ensure => present,
  provider => useradd,
  groups => ['adm','dialout', 'cdrom', 'plugdev', 'netdev',],
  managehome => true,
  shell => '/bin/bash',
  expiry => '2099-12-31',
  password_min_age => '30',
  password_max_age => '3000',
  password => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/', # elexisTest
}

setpass { "elexisDemoUser":
  hash => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/'
  }

