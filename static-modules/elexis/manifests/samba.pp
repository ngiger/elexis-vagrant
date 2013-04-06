#== Class: elexis::samba
#
# Installs and sets up a Samba server
class elexis::samba (
  $sambaBase            = '/opt/samba'
) inherits elexis::common {
  include samba
  include samba::server::config
  $augeas_packages = "['augeas-lenses', 'augeas-tools', 'libaugeas-ruby']"
  package{ ['augeas-lenses', 'augeas-tools', 'libaugeas-ruby']:  ensure => present, }
  
  class {'samba::server':
    workgroup => 'example',
    server_string => "Samba Server for an Elexis practice",
    interfaces => "eth0 lo",
    security => 'share',
    require => [ Package['augeas-lenses', 'augeas-tools', 'libaugeas-ruby'], ],
  }
  
  if (0 == 1) {
  samba::server::share {'share-elexis':
    comment => 'Elexis and other useful tools',
    path => "$sambaBase/share",
    guest_only => true,
    guest_ok => true,
    guest_account => "guest",
    browsable => true,
    create_mask => 0777,
    force_create_mask => 0777,
    directory_mask => 0777,
    force_directory_mask => 0777,
    force_group => 'elexis',
    force_user => 'elexis',
#    copy => 'some-other-share',
    require => [ User['elexis'], Group['elexis'],
      Package['augeas-lenses', 'augeas-tools', 'libaugeas-ruby'], ],
  }
  }
}