# Here we define all the LaTeX packages, which we need to create Elexis documentation

class elexis::download_floatflt inherits elexis::common {
  package {['texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']:
    ensure => present,
  }
  exec { "floatflt.zip":
    command => "wget --timestamp http://mirror.ctan.org/macros/latex/contrib/floatflt.zip",
    creates => $destZip,
    cwd => $downloadDir,
    path => '/usr/bin:/bin',
    require => File[$downloadDir],
    notify => Class['elexis::add_floatflt'],
  }
}

class elexis::add_floatflt inherits elexis::common {
  # Add the latex package floatflt

  include elexis::download_floatflt
  $destDir  = '/usr/share/texmf/tex/latex/misc'
  $floatStyName = "$destDir/floatflt.sty"
  file {$destDir:
    ensure => directory,
  }

  if !defined(Package['unzip']) { package {'unzip': ensure => present, } }
#  install_floatflt($destDir,$destZip)
  exec {$floatStyName:
    command => "unzip ${destZip} && cd floatflt && latex floatflt.ins && cp floatflt.sty ${floatStyName} && texhash",
    creates => $floatStyName,
    cwd => "/tmp",
    path => '/usr/bin:/bin',
    require => Package['unzip', 'texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra'],
  }
}

class elexis::latex inherits elexis::common {
  include elexis::add_floatflt
}

