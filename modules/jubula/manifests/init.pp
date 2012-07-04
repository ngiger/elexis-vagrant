class jubula {

  # Puppet 2.7 cannot serve https-URL directly. Therefore we will use curl/wget to do the job
  $jubulaURL = 'http://s3.amazonaws.com/jubula/setup.sh'
  $destDir = '/usr/local/jubula_6_2'
  $setupSh = '/opt/downloads/jubula_setup_6_2.sh'
  $scriptName = '/opt/downloads/script.exp'
#  package{ 'curl':
#    ensure => present,
#  }
  file{ '/opt/downloads':
    ensure => directory,
  }
  exec{ 'get_jubula':
    command => "wget --no-check-certificate -O $setupSh  $jubulaURL",
#    require => Package['wget'],
    unless => "/usr/bin/test -f ${scriptName }",
    path => '/usr/bin:/bin',
  }
  file{ $scriptName:
    ensure => present,
    source => "puppet:///modules/jubula/script.exp"
  }
  notify{ "test before installtion": }
  installJubula($jubulaURL, $setupSh, $destDir, $scriptName)
}

