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
  include elexis::common 
  include java
  $installDir         =   "$installBase/$version"
  # notify{"install Elexis $version from $programURL into $installDir": }
  
  file { "$installBase":
    ensure => directory,
    owner  => 'elexis',
    mode  => 0755,
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
  
  if !defined(Package['wget']) { package{'wget': ensure => present, } }
  exec { "wget_$installer":
    cwd     => "/tmp",
    command => "wget '$programURL' --output-document=$installer",
    require => [ User['elexis'], File[ "$installBase" ], Package['wget'] ],
    path    => '/usr/bin:/bin',
    creates => "$installer",
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
    require => [ File[ "$installBase"], Exec["wget_$installer"], ],
    path    => '/usr/bin:/bin',
  }

  $logicalLink = "/usr/local/bin/$title"
  file { $logicalLink:
    ensure => link,
    target => "$fullExecPath",
    mode   => 0755,
    require => Exec["$fullExecPath"],
  }
}