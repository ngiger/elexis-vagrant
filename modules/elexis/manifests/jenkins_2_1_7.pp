# Here we setup a few 2.1.7 related jenkins job configuration files
# TODO: Split this up into jenkins-base, user. Use ERB-templates for common tasks like poll, building.

notify { "This is elexis::jenkins_2_1_7": }

file { '/var/lib/jenkins/jobs':
  ensure => directory, # so make this a directory
}

class elexis::constants {
  $jubulaRoot = '/var/lib/jenkins'
  $downloadDir = "${jubulaRoot}/downloads"
  $destZip = "${downloadDir}/floatflt.zip"
}

class elexis::download_floatflt inherits elexis::constants {
  exec { "floatflt.zip":
    command => "wget --timestamp http://mirror.ctan.org/macros/latex/contrib/floatflt.zip",
    creates => $destZip,
    cwd => $downloadDir,
    path => '/usr/bin:/bin',
    require => File[$downloadDir],
    notify => Class['elexis::add_floatflt'],
  }
}

class elexis::add_floatflt inherits elexis::constants {
  # Add the latex package floatflt
  $floatStyName = '/usr/share/texmf/tex/latex/misc/floatflt.sty'
  exec {$floatStyName:
    command => "unzip ${destZip} && cd floatflt && latex floatflt.ins && cp floatflt.sty ${floatStyName} && texhash",
    creates => $floatStyName,
    cwd => "/tmp",
    path => '/usr/bin:/bin',
  }
}

class {
      'elexis::download_floatflt': stage => first;
      'elexis::add_floatflt': stage => main;
    }

define elexis::install_eclipse_version(
  $baseURL,
  $file_base = $title,
  $downloadDir = '/var/lib/jenkins/downloads',
 ) {
  $fullName = "$downloadDir/$filename"
  $cmd = "wget --timestamping ${baseURL}"
  notify {"version-cdm  ${cmd} title ${title}":}
  notify {"unless-cdm ${downloadDir}/${title}":}
  Exec {
    cwd => $downloadDir,
    path => '/usr/bin:/bin',
    require => File[$downloadDir],
  }

  $win32 = "win32.zip"
  exec { "${file_base}-$win32":
    command => "${cmd} ${baseURL}/${title}-$win32",
    creates => "${downloadDir}/${title}-$win32",
  }

  $linux32 = "linux-gtk.tar.gz"
  exec { "${file_base}-$linux32":
    command => "${cmd} ${baseURL}/${title}-$linux32",
    creates => "${downloadDir}/${title}-$linux32",
  }

  $linux64 = "linux-gtk-x86_64.tar.gz"
  exec { "${file_base}-$linux64":
    command => "${cmd} ${baseURL}/${title}-$linux64",
    creates => "${downloadDir}/${title}-$linux64",
  }

  $macosx64 = "macosx-cocoa-x86_64.tar.gz"
  exec { "${file_base}-$macosx64":
    command => "${cmd} ${baseURL}/${title}-$macosx64",
    creates => "${downloadDir}/${title}-$macosx64",
  }
}

define elexis::add_jenkins_jobs(
  $configXML,
  $jobName = $title,
  $downloadDir = '/var/lib/jenkins',
) {
  # specify some default values for all files to be created,
  File {
    owner => 'jenkins',
    mode => '644',
    notify => Service['jenkins'],
    require => [Class["jenkins::package"],Package["jenkins"], User['elexis']]
  }

  file { "/var/lib/jenkins/jobs/$jobName":
    ensure => directory, # so make this a directory
  }

  file { "/var/lib/jenkins/jobs/$jobName/downloads":
    ensure => link, # so make this a link
    target => "/var/lib/jenkins/downloads",
  }

  file { "/var/lib/jenkins/jobs/$jobName/config.xml":
    source => $configXML,
  }
}

class elexis::jenkins_2_1_7 inherits elexis::common {
  include elexis::add_floatflt
  # include jenkins::repo::debian # This does not work under Ubuntu to get the latest version!!
  class { 'jenkins': version => latest }
  include jenkins
  include jenkins::repo::debian
  include jenkins::service
  # notify {"jenkins ohne tomcat":} # we need to remove these packages under Ubuntu
  package { ['jenkins-plugins', 'libjenkins-remoting-java', 'jenkins-cli']:
    ensure => absent,
  }

  package {['texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']:
    ensure => present,
  }

  jenkins::plugin {
    [ "mercurial", "subversion", "git", "ant", "buckminster", "build-timeout", "cvs", "disk-usage", "javadoc",
      "jobConfigHistory", "copy-to-slave", "locks-and-latches", "ssh-slaves", "ruby", "timestamper", ]:
  }

  # specify some default values for all files to be created,
  File {
    owner => 'jenkins',
    mode => '644',
    notify => Service['jenkins'],

    require => [Class["jenkins::package"],Package["jenkins"], User['elexis']]
  }

  $downloadDir = '/var/lib/jenkins/downloads'
  file { $downloadDir:
  ensure => directory, # so make this a directory
  }

#  $eclipseBaseURL = "http://ftp.medelexis.ch/downloads_opensource/eclipse"
  $eclipseBaseURL = "http://mirror.switch.ch/eclipse/technology/epp/downloads/release/indigo/SR2"

  install_eclipse_version{"eclipse-rcp-indigo-SR2":
    baseURL => $eclipseBaseURL,    
  }

  elexis::add_jenkins_jobs {'poll-elexis-addons-2.1.7':
    configXML => 'puppet:///modules/elexis/poll-elexis-addons-2.1.7/config.xml',
  }

  elexis::add_jenkins_jobs {'poll-elexis-base-2.1.7':
    configXML => 'puppet:///modules/elexis/poll-elexis-base-2.1.7/config.xml',
  }

  elexis::add_jenkins_jobs {'elexis-2.1.7-ant':
    configXML => 'puppet:///modules/elexis/elexis-2.1.7-ant/config.xml',
  }

  elexis::add_jenkins_jobs {'jubula-elexis-2.1.7':
    configXML => 'puppet:///modules/elexis/jubula-elexis-2.1.7/config.xml',
  }

  file { [ '/var/lib/jenkins/users', '/var/lib/jenkins/users/elexis']:
  ensure => directory, # so make this a directory
  }
  file { '/var/lib/jenkins/users/elexis/config.xml':
    ensure => present,
    source => 'puppet:///modules/elexis/users/elexis.xml',
  }

}
