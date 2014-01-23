#
# Here we setup the stuff needed to boot from thin client (e.g. a Zodiac)
# 
# https://wiki.debian.org/LTSP/Howto
# http://wiki.ltsp.org/wiki/Tips_and_Tricks/User_Experience
# https://wiki.debian.org/DebianEdu/Documentation/Wheezy/HowTo/NetworkClients
# We use dnsmasq to provide the tftpboot and setting the DHCP boot-options
# Look at https://github.com:ngiger/vagrant-ngiger on how to setup DNS-Masq
# At praxis-union Luzern the dhcp-service come from a server not controlled by puppet

require stdlib

class elexis::thin_client (
  $boot_host = "192.168.1.222"
) inherits elexis::common {

  package{'ltsp-server': }
  $apt_proxy_host = hiera('apt::proxy_host', 'http://198.168.1.222:3142')
 
  exec{'install-ltsp':
    command => "/usr/sbin/ltsp-build-client --apt-key /etc/apt/trusted.gpg --arch i386 --http-proxy $apt_proxy_host \
    --components 'main contrib non-free' --late-packages 'vim-nox aptitude sudo dnsutils etckeeper firmware-realtek'",
      creates => '/opt/ltsp/i386/etc/passwd',
      require => Package['ltsp-server'],
  }
  
  augeas{ "/etc/exports" :
      context => "/files/etc/exports",
      changes => [
          "set dir[last()+1] /opt/ltsp",
          "set dir[last()]/client *",
          "set dir[last()]/client/option[1] ro",
          "set dir[last()]/client/option[2] no_root_squash",
          "set dir[last()]/client/option[3] async",
          "set dir[last()]/client/option[4] no_subtree_check",
      ],
      onlyif => "match dir[. = '/opt/ltsp'] size == 0",
  }

  # TODO: Limit this to process like portmap and nfs and to local subnet
  augeas{ "/etc/hosts.allow" :
      context => "/files/etc/hosts.allow",
      changes => [
          "set 01/process[last()+1] ALL",
          "set 01/client[last()] ALL",
      ],
      onlyif  => "match *[process='ALL'] size == 0", 
  }
}
