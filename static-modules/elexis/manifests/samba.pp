#== Class: elexis::samba
#
# Installs and sets up a Samba server
class elexis::samba (
  $sambaBase            = '/opt/samba',
  $sambaPraxis          = "/opt/samba/elexis",
  $sambaPdf             = "/opt/samba/elexis/neu",
) inherits elexis::common {
  include samba
  include samba::server::config
  $augeas_packages = "['augeas-lenses', 'augeas-tools', 'libaugeas-ruby']"
  ensure_packages(['augeas-lenses', 'augeas-tools', 'libaugeas-ruby', 'cups-pdf', 'cups-bsd'])
  
  class {'samba::server':
    workgroup => 'Praxis',
    server_string => "Samba Server for an Elexis practice",
    interfaces => "eth0 eth2 lo",  # eth2 ist für vagrant
    security => 'share',
    require => [ Package['augeas-lenses', 'augeas-tools', 'libaugeas-ruby'], ],
  }
  
  file{[$sambaBase, "$sambaPraxis",  "$sambaPdf"]: 
    ensure => directory,
    group => 'elexis',
    owner => 'elexis',
    require => User['elexis'],
    mode    => 0664,
  }
  
  samba::server::share {'elexis':
    comment => 'Elexis and other useful tools',
    path => "$sambaPraxis",
    guest_only => false,
    guest_ok => true,
    guest_account => "guest",
    browsable => true,
    create_mask => 0777,
    force_create_mask => 0777,
    directory_mask => 0777,
    force_directory_mask => 0777,
    force_group => 'elexis',
    force_user => 'elexis',
    require => [ User['elexis'],
      Package['augeas-lenses', 'augeas-tools', 'libaugeas-ruby'], ],
  }
  samba::server::share {'homes':
    comment => 'Benutzerspezfische Verzeichnisse (Home)',
    browsable => false,
    force_user => '%S',
#    valid_users => '%S',
    guest_only => false,
    guest_ok => false,
    create_mask => 0600,
    directory_mask => 0700,
  }
  
  samba::server::share {'pdf-ausgabe':
    comment => 'Ausgabe für Drucken in Datei via PDF',
    path => "$sambaPdf",
    browsable => true,
    read_only => true,
    force_user => '%S',
#    valid_users => '%S',
    guest_only => false,
    guest_ok => false,
    create_mask => 0600,
    directory_mask => 0700,
  }
  
  file{'/etc/cups/cups-pdf.conf':
  content => '# managed by puppet! elexis/manifests/samba.pp
Out ${HOME}/pdf
Label 0
UserUMask 0002

Grp lpadmin
LogType 3

PostProcessing /usr/local/bin/cups-pdf-renamer
',
  mode => 0644,
  require => Package['cups-pdf'],
  }

  file{'/usr/local/bin/cups-pdf-renamer':
  content => "#!/bin/bash
# managed by puppet! elexis/manifests/samba.pp
FILENAME=`basename \$1`
# CURRENT_USER=\"\${2}\"
# CURRENT_GROUP=\"\${3}\"
DATE=`date +\"%Y-%m-%d_%H:%M:%S\"`
umask=022
sudo -u \$2 mv \$1 $sambaPdf/\$FILENAME && logger cups-pdf moved \$1 to $sambaPdf/\$FILENAME
",
  mode => 0755,
  }
}