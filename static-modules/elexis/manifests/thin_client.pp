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

  $useDnsmasq = hiera('elexis::useDnsmasq', false)

  if (  $useDnsmasq) { # at the moment we don't want it
    ensure_packages['dnsmasq']
    file{"/etc/dnsmasq.d/thinclient.conf":
      content => "# $managed_note
# Minimal dnsmasq configuration for PXE client booting 

# The rootpath option is used by both NFS and NBD.
dhcp-option=17,/opt/ltsp/i386

# Define common netboot types.
dhcp-vendorclass=pxe,PXEClient

# Set the boot filename depending on the client vendor identifier.
# The boot filename is relative to tftp-root.
dhcp-boot=/ltsp/i386/pxelinux.0,server,$boot_host

# Kill multicast.
dhcp-option=vendor:pxe,6,2b

# Disable re-use of the DHCP servername and filename fields as extra
# option space. That's to avoid confusing some old or broken DHCP clients.
dhcp-no-override

# The known types are x86PC, PC98, IA64_EFI, Alpha, Arc_x86,
# Intel_Lean_Client, IA32_EFI, BC_EFI, Xscale_EFI and X86-64_EFI
pxe-service=X86PC, 'Boot thinclient from network', /ltsp/i386/pxelinux,$boot_host

# Comment the following to disable the TFTP server functionality of dnsmasq.
#enable-tftp

# The TFTP directory. Sometimes /srv/tftp is used instead.
#tftp-root=/var/lib/tftpboot/
",
        mode => 0744,
    }  
  } # only if dnsmasq is required
  
  ensure_packages['ltsp-server', 'dnsmasq']
  file{'/etc/default/tftpd-hpa':
    ensure => present,
    content => '
TFTP_USERNAME="tftp"
# no trailing slash for TFTP_DIRECTORY!!
TFTP_DIRECTORY="/var/lib/tftpboot" 
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
',
    }
  package{'tftpd-hpa':
    ensure => installed,
    require => File['/etc/default/tftpd-hpa'],
  }
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
