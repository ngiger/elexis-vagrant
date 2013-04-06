case $lsbdistcodename {
  "squeeze":  { $eclipseVersion = 'latest' }
  default : {  $eclipseVersion = '3.7.2-1' }
}

class eclipse($version = $eclipseVersion) {
  package { ['eclipse-rcp', 'eclipse']:
    ensure => $version,
  }
}
