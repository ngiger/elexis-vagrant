# == Class: elexis::windows
#
# Installs the (Med-)Elexis Version into a $sambaBase/<version>
# for WINDOWS!!!
# We use OpenJDK7 under wine to run the installer (from http://jdk7.java.net/java-se-7-ri/)
class elexis::windows (
  $programURL             = 'http://www.medelexis.ch/dl21.php?file=medelexis-windows',
  $version                = 'current',
  $installBase            = "$sambaBase/elexis-windows",
  $auto_windows_template  = 'elexis/auto_install.xml.erb'
) inherits elexis::samba {

  $installDir         =   "$installBase/$version"
#  notify{"windows Elexis $version from $programURL into $installBase": }
  
  # just a few 80 MB
  $openjdkUrl = "http://download.java.net/openjdk/jdk7/promoted/b146/gpl/openjdk-7-b146-windows-i586-20_jun_2011.zip"
  $openjdkDownload = "$installBase/openjdk-7-b146-windows-i586-20_jun_2011.zip"

  package{['xvfb', 'wine']: }
  
  if !defined(Exec["$installDir"]) {
    exec { "$installDir":
#      command => "/bin/mkdir -p $installDir && /bin/chown elexis $installDir",
      command => "/bin/mkdir -p $installDir",
 #     user  => 'root',
      creates => "$installDir",
      unless => "/usr/bin/test -d $installDir",
      require => [ User['elexis'] ],
    }
  }
  
  exec { "$openjdkDownload":
    command => "wget $openjdkUrl  --output-document=$openjdkDownload",
#    user  => 'root',
    creates => "$openjdkDownload",
    require => [ Exec["$installDir"] ],
    path => "/usr/local/bin:/usr/bin:/bin",
  }
  
  $installed_java_exe = "$sambaBase/java-se-7-ri/bin/java.exe"
  exec { "$installed_java_exe":
    command => "unzip $openjdkDownload",
#    user  => 'root',
    cwd   => "$sambaBase",
    creates => "$installed_java_exe",
    require => [ Exec["$openjdkDownload"] ],
    path => "usr/local/bin:/usr/bin:/bin",
  }
  
  $autoInstallXml = "$installBase/auto_windows-$version.xml"
  $installer      = "$installBase/elexis-installer-$version.jar"
#  notify{"windows $auto_windows_template via $autoInstallXml and $installer  $installDir": }
  
  file { "$autoInstallXml":
    content => template("$auto_windows_template"),
    owner  => 'elexis',
    mode  => 0644,
    require => [ User['elexis'], Exec[ "$installDir" ] ],
  }

  if !defined(Package['wget']) { package{'wget': ensure => present, } }
  exec { "wget_$installer":
    cwd     => "/tmp",
    command => "wget '$programURL' --output-document=$installer",
    require => [ User['elexis'],  Exec[ "$installDir" ], Package['wget'] ],
    path    => '/usr/bin:/bin',
    creates => "$installer",
    timeout => 1800, # allow maximal 30 minutes for download
 }
  
  
  $elexis_windows_exe = "$installDir/elexis.exe"
  notify{"Creating Windows elexis.exe at $elexis_windows_exe":}

  # running wine and xvfb. Example from http://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/indexa073.html
  # Also we need the following
  # dpkg --add-architecture i386
  # apt-get update
  # apt-get install wine-bin:i386
  
  exec { "$elexis_windows_exe":
    cwd     => "/tmp",
    command => "wine $installed_java_exe -jar $installer $autoInstallXml",
    creates => "$elexis_windows_exe",
    require => [ File["$autoInstallXml"], 
      Exec["$installDir", "wget_$installer", "$installed_java_exe"], 
      Package['wine', 'xvfb'], # we need an X environment for wine
      ],
    path    => '/usr/bin:/bin',
  }

}