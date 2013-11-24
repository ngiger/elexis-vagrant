# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

  # TODO: add non-free firmware to the chroot
  # TODO: x2gothinclient_update
  # TODO: add possibility to customize 

class elexis::x2go_customize inherits elexis {
  $tce_base   = "/opt/x2gothinclient"
  $tce_chroot = "$tce_base/chroot"
  
  x2go::tce{'need_x2go_tce': x2go_tce_base => $tce_base}
  
  file{"/srv/tftp/local-boot.cfg":
    ensure => absent,
    require => Exec['x2go::tce::x2gothinclient_preptftpboot'],
  }
  
  file{"/srv/tftp/elexis-tce-splash.png":
    source => 'puppet:///modules/elexis/elexis-tce-splash.png',
    require => Exec['x2go::tce::x2gothinclient_preptftpboot'],
    }

  file{"/srv/tftp/elexis.cfg":
    content => "LABEL x2go-tce-486
        MENU LABEL  ^Elexis x2go-thin-client 
        KERNEL vmlinuz.486
        APPEND initrd=initrd.img.486 nfsroot=$tce_chroot quiet boot=nfs ro nomodeset splash
    ",
    require => Exec['x2go::tce::x2gothinclient_preptftpboot'],
  }
  
  file{'/srv/tftp/default.cfg':
    content  => "DEFAULT vesamenu.c32
PROMPT 0
MENU BACKGROUND elexis-tce-splash.png
MENU TITLE Elexis: X2Go Thin Client 

include elexis.cfg
MENU SEPARATOR
include memtest.cfg

# menu settings
MENU VSHIFT 3
MENU HSHIFT 18
MENU WIDTH 60
MENU MARGIN 10
MENU ROWS 12
MENU TABMSGROW 13
MENU CMDLINEROW 23
MENU ENDROW 12
MENU TIMEOUTROW 18

MENU COLOR border       30;44      #40ffffff #a0000000 std
MENU COLOR title        1;36;44    #9033ccff #a0000000 std
MENU COLOR sel          7;37;40    #e0000000 #20ffffff all
MENU COLOR unsel        37;44      #50ffffff #a0000000 std
MENU COLOR help         37;40      #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40      #80ffffff #00000000 std
MENU COLOR timeout      1;37;40    #c0ffffff #00000000 std
MENU COLOR msg07        37;40      #90ffffff #a0000000 std
MENU COLOR tabmsg       37;40      #e0ffffff #a0000000 std
MENU COLOR disabled     37;44      #50ffffff #a0000000 std
MENU COLOR hotkey       1;30;47    #ffff0000 #a0000000 std
MENU COLOR hotsel       1;7;30;47  #ffff0000 #20ffffff all
MENU COLOR scrollbar    30;47      #ffff0000 #00000000 std
MENU COLOR cmdmark      1;36;47    #e0ff0000 #00000000 std
MENU COLOR cmdline      30;47      #ff000000 #00000000 none

# possible boot profiles for ONTIMEOUT: 
# localboot, x2go-tce-686, x2go-tce-486
# (... or any other profile you defined in your customized menu)
ONTIMEOUT x2go-tce-486
TIMEOUT 30
",
    require => Exec['x2go::tce::x2gothinclient_preptftpboot'],
  }
  file{"$tce_base/etc/x2gothinclient_sessions":
    content => template("elexis/x2go_session.erb"),
    require => Exec['x2go::tce::x2gothinclient_create'],
    notify  => Exec['x2gothinclient_update'],
  }
  file{"$tce_base/etc/x2gothinclient_start":
    content => template("elexis/x2gothinclient_start.erb"),
    require => Exec['x2go::tce::x2gothinclient_create'],
    notify  => Exec['x2gothinclient_update'],
  }
  file{"$tce_chroot/etc/elexis32.png":
    source => 'puppet:///modules/elexis/elexis32.png',
    require => Exec['x2go::tce::x2gothinclient_create'],
    notify  => Exec['x2gothinclient_update'],
  }
  file{"$tce_chroot/etc/elexis-tce-splash.svg":
    source => 'puppet:///modules/elexis/elexis-tce-splash.svg',
    require => Exec['x2go::tce::x2gothinclient_create'],
    notify  => Exec['x2gothinclient_update'],
  }
  
  
  exec{'x2gothinclient_update':
    require => File["$tce_base/etc/x2gothinclient_sessions", "$tce_base/etc/x2gothinclient_sessions", "$tce_chroot/etc/elexis-tce-splash.svg"],
    command => 'sudo -iuroot x2gothinclient_update', # we need to use sudo or x2go will complain!
    path => '/usr/local/bin:/usr/bin/:/bin:/usr/sbin:/sbin',
    creates => "${chroot}/etc/x2go/x2gothinclient_sessions",
  }
}
