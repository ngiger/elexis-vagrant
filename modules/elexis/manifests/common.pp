# Here we define a few packages which are common to all elexis instances
class elexis::common {

  include java
  package{  ['vim', 'vim-nox', 'vim-puppet', 'git', 'etckeeper', 'puppet', 'dlocate', 'mlocate', 'htop']:
    ensure => present,
  }

  group { 'elexis':
    ensure => present,
    gid => 1300,
  }

  user { 'elexis':
    ensure => present,
    uid => 1300,
    gid => 'elexis',
    groups => ['adm','dialout', 'cdrom', 'plugdev', 'netdev',],
    home => '/home/elexis',
    managehome => true,
    password => '$6$dhRZ0TiE$7XqShTeGp2ukRiMdGVyk/JIqbvRtwySwFkYaK3sbNxrH1vI9gvsBI7pdjYlugL/bgYavsx0wL3Z2CLJGKyBkN/', # elexisTest
    password_max_age => '99999',
    password_min_age => '0',
  }


}
