# Here we define all the LaTeX packages, which we need to create Elexis documentation

class elexis::latex ( 
  $destDir  = '/usr/share/texmf/tex/latex/misc',
  $floatStyName = "$destDir/floatflt.sty",
  $floatfltURL = 'http://mirror.ctan.org/macros/latex/contrib/floatflt.zip',
)
inherits elexis::common {
  if !defined(Package['unzip']) { package {'unzip': ensure => present, } } 
  package {['texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']:
    ensure => present,
  }

  $cmd = "wget --timestamp -O ${destZip} ${floatfltURL}"
  exec {"X$destZip":
    command => $cmd,
    creates => $destZip,
    cwd => $elexis::downloadDir,
    path => '/usr/bin:/bin',
    require => File[$elexis::downloadDir],
  }

  exec { "$destDir":
    command => "mkdir -p $destDir",
    path => '/usr/bin:/bin',
    creates => "$destDir"
  }

  $cmdFile = "/${elexis::downloadDir}/install_floatflt.sh"
  file {"$cmdFile":
    mode => 0755,
    content => "#!/bin/bash -v
cd $elexis::downloadDir
# Just in case we got called a second time
rm -rf floatflt
unzip ${destZip}
cd floatflt
latex floatflt.ins
cp floatflt.sty ${floatStyName} && texhash
",
  }


  exec {"$floatStyName":
    command => $cmdFile,
    creates => $floatStyName,
    cwd => $elexis::downloadDir,
    path => '/usr/bin:/bin',
    require => [File[$cmdFile],
		Exec[$destDir, "X$destZip"],
		Package['unzip', 'texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']],
  }
}

# class {['elexis::latex']: stage => last; } # I want the interesting things to load first!
