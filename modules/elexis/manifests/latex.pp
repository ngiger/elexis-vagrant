# Here we define all the LaTeX packages, which we need to create Elexis documentation

class elexis::download_floatflt inherits elexis::common {
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
  $floatStyName = '/usr/share/texmf/tex/latex/misc/floatflt.sty'
  exec {$floatStyName:
    command => "unzip ${destZip} && cd floatflt && latex floatflt.ins && cp floatflt.sty ${floatStyName} && texhash",
    creates => $floatStyName,
    cwd => "/tmp",
    path => '/usr/bin:/bin',
    require => Package['unzip', 'texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra'],
  }
}

class elexis::latex inherits elexis::common {
  package {['texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']:
    ensure => present,
  }

}

