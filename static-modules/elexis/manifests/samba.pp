#== Class: elexis::samba
#
# Installs and sets up a Samba server
# TODO: Create initial password for all Samba-Users
class elexis::samba (
  $sambaBase            = '/opt/samba',
  $sambaPraxis          = "/opt/samba/elexis",
  $sambaPdf             = "/opt/samba/elexis/neu",
) inherits elexis::common {
  include samba
  include samba::server::config
  $augeas_packages = "['augeas-lenses', 'augeas-tools', 'libaugeas-ruby']"
  $with_x2go        = hiera('x2go::ensure')
  ensure_packages(['augeas-lenses', 'augeas-tools', 'libaugeas-ruby', 'cups-pdf', 'cups-bsd'])

  class {'samba::server':
    server_string => "Samba Server for an Elexis practice",
    interfaces => hiera('samba::server::interfaces', ['eth0']),
    require => [ Package['augeas-lenses', 'augeas-tools', 'libaugeas-ruby'], ],
  }
  
  file{[$sambaBase, "$sambaPraxis",  "$sambaPdf"]: 
    ensure => directory,
    group => 'elexis',
    owner => 'elexis',
    require => User['elexis'],
    mode    => 0664,
  }
  
  $share_definition = hiera('samba::server::shares', undef)
  if ($share_definition) {
    # notify{"samba $share_definition $share_definition": }
    elexis_samba_shares{"elexis_shares":  share_definition => $share_definition}
  }
  define elexis_samba_shares($share_definition) {    
    if ($share_definition) {
      add_samba_share{$share_definition:}
    }
  }
  define add_samba_share() {
    $share_name = $title['name']
    $path       = $title['path']
    samba::server::share{"$share_name":
      browsable => $title['browsable'],
      comment => $title['comment'],
      copy => $title['copy'],
      create_mask => $title['create_mask'],
      directory_mask => $title['directory_mask'],
      # don't pass not force_parameters which only produce errrors with samba 3
      guest_account => $title['guest_account'],
      guest_ok => $title['guest_ok'],
      guest_only => $title['guest_only'],
      path => $path,
      public => $title['public'],
      write_list => $title['write_list'],
      writable => $title['writable'],
      printable => $title['printable'],
      valid_users => $title['valid_users'],
      force_user => $title['force_user'],
      force_group => $title['force_group'],
      op_locks => $title['op_locks'],
      veto_oplock_files =>  $title['veto_oplock_files'], 
      level2_oplocks => $title['level2_oplocks'],
 
#      onlyif => "/usr/bin/test -d $path",
    }
    if ($path) { file{"$path": ensure => directory} }
  }
  samba::server::share {'pdf-ausgabe':
    comment => 'Ausgabe für Drucken in Datei via PDF',
    path => "$sambaPdf",
    browsable => true,
    read_only => true,
    force_user => '%S',
    guest_only => false,
    guest_ok => false,
    create_mask => 0600,
    directory_mask => 0700,
  }
  
  $server_options =  hiera('samba::server::options', 'dummy')
  if ($server_options) {
    elexis_samba_options{"elexis_samba_options": option_definition => $server_options}
  }
  define elexis_samba_options($option_definition = undef) {
    if ($server_options) {
      add_samba_option{"add_samba_option $option_definition":}
    }
  }
  
  define add_samba_option() {
    $option_name = $title['name'] 
    set_samba_option{"$option_name":
      value => $title['value'],
      name  => $option_name,
    }
  }
  define set_samba_option ($name, $value, $signal = 'samba::server::service' ) {
    $context = $samba::server::context # /files/etc/samba/smb.conf
    $target = $samba::server::target #
    $changes = $value ? {
      default => "set \"${target}/$name\" \"$value\"",
      '' => "rm ${target}/$name",
    }
    $name_for = regsubst($name, ' ', '\\ ')
    $match_expression = "get \"$context/${target}/$name\" != \"$value\""
    augeas { "samba_$name_for":
      context => $context,
      changes => $changes,
      require => Augeas['global-section'],
      notify => Class[$signal],
      onlyif => "$match_expression",
    }
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
  
  if ("$with_x2go") {
    ensure_packages(['wget'])
    $win_version = '4.0.0.3'
    $mac_version = '4.0.1.0'
    $wget_x2go_win_client = "${sambaBase}/X2GoClient_latest_mswin32-setup.exe"
    $wget_x2go_mac_client = "${sambaBase}/X2GoClient_latest_macosx.dmg"
    
    exec { "$wget_x2go_mac_client":
      cwd     => "${sambaBase}",
      command => "wget --timestamping http://code.x2go.org/releases/X2GoClient_latest_mswin32-setup.exe",
      require => [File["$sambaBase"], Package['wget'] ],
      path    => '/usr/bin:/bin',
      timeout => 1800, # allow maximal 30 minutes for download
      creates => $wget_x2go_mac_client,
    }
    
    exec { "$wget_x2go_win_client":
      cwd     => "${sambaBase}",
      command => "wget --timestamping http://code.x2go.org/releases/X2GoClient_latest_macosx.dmg",
      require => [File["$sambaBase"], Package['wget'] ],
      path    => '/usr/bin:/bin',
      timeout => 1800, # allow maximal 30 minutes for download
      creates => $wget_x2go_mac_client,
    }
  }
}