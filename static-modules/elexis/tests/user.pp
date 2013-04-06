user { 'elexisDemoUser':
  ensure => present,
  groups => ['adm','dialout', 'cdrom', 'plugdev', 'netdev',],
  managehome => true,
  shell => '/bin/bash',
  password => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/', # elexisTest
}
