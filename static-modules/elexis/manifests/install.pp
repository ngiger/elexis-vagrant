# == Class: elexis::install
#
# Installs the (Med-)Elexis Version into a $installBase/<version>
# todo: get info about installed version
# you can have more than one installation in parallel

define elexis::install (
  $programURL             = 'http://www.medelexis.ch/dl21.php?file=medelexis-linux',
  $version                = 'current',
  $installBase            = '/opt/elexis',
  $auto_install_template  = 'elexis/auto_install.xml.erb'
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
  
  $autoInstallXml = "$installBase/auto_install-$version.xml"
  $installer      = "$installBase/elexis-installer-$version.jar"
  # notify{"install $auto_install_template via $autoInstallXml and $installer": }
  
  file { "$autoInstallXml":
    content => template("$auto_install_template"),
    owner  => 'elexis',
    mode  => 0644,
    require => [ User['elexis'], File[ "$installBase" ] ],
  }

  if !defined(Package['wget']) { package{'wget': ensure => present, } }
  exec { "wget_$installer":
    cwd     => "/tmp",
    command => "wget '$programURL' --output-document=$installer",
    require => [ User['elexis'], File[ "$installBase" ], Package['wget'] ],
    path    => '/usr/bin:/bin',
    creates => "$installer",
  }
  
  $fullExecPath = "$installDir/elexis"

  exec { "$fullExecPath":
    cwd     => "/tmp",
    command => "echo pwd
    echo $installDir &&
    java -jar $installer $autoInstallXml
    ls -l $installDir/elexis",
    creates => "$fullExecPath",
    require => [ File[ "$installBase", "$autoInstallXml"], Exec["wget_$installer"], ],
    path    => '/usr/bin:/bin',
  }

  $logicalLink = "/usr/local/bin/$title"
  notify{"elexis install $logicalLink": }
  file { $logicalLink:
    ensure => link,
    target => "$fullExecPath",
    mode   => 0755,
    require => Exec["$fullExecPath"],
  }
}