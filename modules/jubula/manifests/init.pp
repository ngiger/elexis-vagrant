class jubula {

  # Puppet 2.7 cannot serve https-URL directly. Therefore we will use curl/wget to do the job
  # setup.sh is a 32-bit application. http://www.eclipse.org/forums/index.php/m/893607/#msg_893607
  # therefore we need the ia32-libs

  $jubulaURL = 'http://s3.amazonaws.com/jubula/setup.sh'
  $destDir = '/usr/local/jubula_6_2'
  $setupSh = '/opt/downloads/jubula_setup_6_2.sh'
  $scriptName = '/opt/downloads/script.exp'

  
  file{ '/opt/downloads':
    ensure => directory,
  }
  exec{ 'get_jubula':
    command => "wget --no-check-certificate -O $setupSh  $jubulaURL",
    unless => "/usr/bin/test -f ${scriptName }",
    require => Package['curl'], # curl is defined in site.pp
    path => '/usr/bin:/bin',
  }

  package{['expect', 'ia32-libs']:
    ensure => present,
  }

  file{ '/usr/local':
    ensure => directory,
    owner => 'vagrant',
  }

  file{ $destDir:
    ensure => directory,
    owner => 'vagrant',
  }

  file{ $scriptName:
    owner => 'vagrant',
    ensure => present,
    mode => 0777,
    source => "puppet:///modules/jubula/script.exp",
    require => [Package['curl', 'expect', 'ia32-libs']],
  }
  file { '/usr/local/bin/jubula':
    ensure => link,
    target => "${destDir}/jubula/jubula",
    owner  => 'root',
    mode => 0755,
  }

  class jubula::install inherits jubula {
    installJubula($jubulaURL, $setupSh, $destDir, $scriptName)
  }
  class {'jubula::install':stage => last; }

}

