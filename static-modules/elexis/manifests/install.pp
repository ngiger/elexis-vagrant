# == Class: elexis::install
#
# Installs the (Med-)Elexis Version into a $installBase/<version>
# todo: get info about installed version
# you can have more than one installation in parallel

define elexis::install (
  $programURL             = 'http://www.medelexis.ch/dl21.php?file=medelexis-linux',
  $version                = 'current',
  $installBase            = '/opt/elexis',
) {
  include elexis::admin
  include elexis::common 
  include java
  $installDir         =   "$installBase/$version"
  # notify{"install Elexis $version from $programURL into $installDir": }
  
  file { "$installBase":
    ensure => directory,
    owner  => 'elexis',
    mode  => 0666,
    require => [ User['elexis'] ];
  }

  if !defined(File["$installDir"]) {
    file { "$installDir":
      ensure => directory,
      owner  => 'elexis',
      mode  => 0755,
      require => [ User['elexis'], File[ "$installBase" ] ],
    }
  }
  
  $installer      = "$installBase/elexis-installer-$version.jar"
  # elexis always wants to open a pdf with evince and not okular
  # Debian sets evince as default pdf-viewer in /etc/mailcap or ~/.mailcap
  if !defined(Package['evince']) { package{'evince': ensure => present, } }
  if !defined(Package['iceweasel']) { package{'iceweasel': ensure => present, } }

  if !defined(Package['wget']) { package{'wget': ensure => present, } }
  exec { "wget_$installer":
    cwd     => "/tmp",
    command => "wget '$programURL' --output-document=$installer",
    require => [ User['elexis'], File[ "$installBase" ], Package['wget'] ],
    path    => '/usr/bin:/bin',
    unless => "test -s $installer",
  }
  
  $installer_script = '/usr/local/bin/install_elexis.rb'
  if !defined(File[$installer_script]) {
    file{$installer_script:
      source => 'puppet:///modules/elexis/install_elexis.rb',
      mode => 0755,
      owner => root,
      group => root,
    }
  }

  $fullExecPath = "$installDir/elexis"
  exec { "$fullExecPath":
    cwd     => "/tmp",
    command => "$installer_script $installer $installDir",
    creates => "$fullExecPath",
    require => [ File[ "$installBase", '/etc/auto_install_elexis.xml'], Exec["wget_$installer"], ],
    path    => '/usr/bin:/bin',
  }

  $logicalLink = "/usr/local/bin/$title"
  file { $logicalLink:
    ensure => link,
    target => "$fullExecPath",
    mode   => 0755,
    require => Exec["$fullExecPath"],
  }
  # add a menu entry for KDE, e.g. /usr/share/applications/kde4/kmail_view.desktop
  if false {
    notify{"kde4: Has problem with first bringup":}
    file { "/usr/share/applications/kde4/${title}.desktop":
      ensure => present,
      content=> "[Desktop Entry]
  Name=Elexis for medical practices
  Name[de]=Elexis für die Praxis ($title)
  Type=Application
  Exec=${title}
  Icon=${title}
  # X-DocPath=kmail/index.html
  # X-KDE-StartupNotify=true
  # X-DBUS-StartupType=Unique
  # X-DBUS-ServiceName=org.kde.kmail
  ",
      mode  => 0644,
      require => [ File[$logicalLink], Class[kde],],
    }

    file { "/usr/share/icons/hicolor/128x128/apps/${title}.png":
      source => 'puppet:///modules/elexis/elexis.png', # copied from ch.ngiger.opensource/splash.png
      mode  => 0644,
      require => File[$logicalLink],
    }
  }
  
}