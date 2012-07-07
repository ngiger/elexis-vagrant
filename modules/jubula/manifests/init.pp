# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
class jubula($jubulaURL = 'http://s3.amazonaws.com/jubula/setup.sh',
  $destDir = '/usr/local/jubula_6_2',
  $setupSh = '/opt/downloads/jubula_setup_6_2.sh') {
  include apt # to force an apt::update
  # Puppet 2.7 cannot serve https-URL directly. Therefore we will use curl/wget to do the job
  # setup.sh is a 32-bit application. http://www.eclipse.org/forums/index.php/m/893607/#msg_893607
  # therefore we need the ia32-libs
  $downloads  = dirname($setupSh)
  $scriptName = "${downloads}/script.exp"
  $jubulaEXE  = "${destDir}/jubula/jubula"
  
  if !defined(Package['wget']) { package{'wget': ensure => present, } }
    
  file{"$downloads":
    ensure => directory,
  }
  
  exec{ 'get_jubula':
    command => "wget --timestamping --no-check-certificate -O ${setupSh}  ${jubulaURL}",
    creates => $setupSh,
    require => Package['wget'], # curl is defined in site.pp
    path => '/usr/bin:/bin',
  }

  package{['expect']:
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
  }

  $cmd2 = "${scriptName} ${setupSh} ${destDir}"
  notify {"install_jubula $cmd2":}
  exec{ $scriptName:
    command => $cmd2,
    creates => $jubulaEXE,
    require => [Package['expect'], Exec['get_jubula']],
  }

  file { '/usr/local/bin/jubula':
    ensure => link,
    target => $jubulaEXE,
    owner  => 'root',
    mode => 0755,
    require => Exec[$scriptName],
  }

  # imagemagick is needed to take snapshots
  # fvwm, vnc4server is needed for running headless under Jenkins
  # I think we will need some configuration too
  # I used the xstartup from the jubula-elexis-project.
  # TODO: configure jenkins node correctly /computer/ng-hp/configure
#  package { ['imagemagick', 'fvwm', 'vnc4server']:
  # jubula needs a 32-bit Java
  case $architecture {
      /amd64/:  {
        package { ['ia32-libs']: ensure => present, }
        Exec[$scriptName] <- Package['ia32-libs']
        case $operatingsystem {
              'Debian':  { }
              'Ubuntu': {
                package { ['openjdk-6-jre-headless:i386']:
                  ensure => present,
                }
              }
              default: { notify { "\n Jubula-Setup: Don't know to handle ${operatingsystem}": } }
        }
      }
      default: { notify { "Jubula-setup: No 32-bit Java needed for ${architecture}": } }
  }

}

