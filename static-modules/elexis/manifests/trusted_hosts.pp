# Here we setup trust between the hosts server and backup for postgresql_server
require stdlib

define elexis::set_user_id_rsa(
  $user_name,
  $allow,
  $deny,
) {
  notify{"set_user_id_rsa $title":}
}

define elexis::id_rsa_users(
  $user_name = undef,
  $allow    = undef,
  $hosts = undef,
)  {
  include stdlib
  $user = $title
  $myArray = join(any2array($hosts), ',')
  if (defined(User[$user]) and member(flatten(any2array($hosts)), $hostname)) {
    $private_rsa_file = "/etc/puppet/hieradata/private/${user}/id_rsa${user}"
    $default_rsa_file = "/etc/puppet/hieradata/${user}/id_rsa"
    $ssh_destination  = "/home/${user}/.ssh"  
    $rsa_name = "$ssh_destination/id_rsa_elexis"
    # notify{"id_rsa_users $user with $title":}
    if (0 == 1) {
    file {$ssh_destination:
      recurse => true,
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => 0600,
    }
    }
    
    exec {"private_rsa_$user":
      command => "$elexis::trusted_hosts::copy_ssh $user",
      require => [ User[$user],File[$elexis::trusted_hosts::copy_ssh],  #  Group[$user], 
      ],
      unless  => "$elexis::trusted_hosts::copy_ssh $user",
    }
    
  } else {
    notify{"no trusted user $user or $hostname not in $myArray":}
  }
}

class elexis::trusted_hosts (
  $copy_ssh = '/usr/local/bin/copy_ssh.sh'
) inherits elexis::common {
  include elexis::postgresql_server
  user{ 'vagrant': }
  group{ 'vagrant': }
  
  sshd_config { "PermitRootLogin":
    ensure    => present,
    value     => "no",
  }
    
  file { "$copy_ssh":
    source => 'puppet:///modules/elexis/copy_ssh.sh',
    mode => 0744,
    owner => root,
    group => root,
  }
  
  $users = hiera_hash('elexis::trusted_hosts', undef)
  if $users {
    create_resources('elexis::id_rsa_users', $users)
  } else {
    notify{"no trusted_hosts defined!":}
  }
  include ssh 
}
