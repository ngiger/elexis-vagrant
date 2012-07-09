# Here we define all the LaTeX packages, which we need to create Elexis documentation

class elexis::latex inherits elexis::common {

  $destDir  = '/usr/share/texmf/tex/latex/misc'
  $floatStyName = "$destDir/floatflt.sty"

  case $elexisFileServer {
        /^http|^ftp/:  { $floatfltURL = "${elexisFileServer}/latex/floatflt.zip" }
        default: { $floatfltURL = 'http://mirror.ctan.org/macros/latex/contrib/floatflt.zip'}
    }

  if !defined(Package['unzip']) { package {'unzip': ensure => present, } } 
  package {['texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']:
    ensure => present,
  }

  $cmd = "wget --timestamp -O ${destZip} ${floatfltURL}"
  exec {$destZip:
    command => $cmd,
    creates => $destZip,
    cwd => $downloadDir,
    path => '/usr/bin:/bin',
    require => File[$downloadDir],
  }

  file {$destDir:
    ensure => directory,
  }

  $cmdFile = "${downloadDir}/install_floatflt.sh"
  file {$cmdFile:
    mode => 0755,
    content => "#!/bin/bash -v
cd ${downloadDir}
# Just in case we got called a second time
rm -rf floatflt
unzip ${destZip}
cd floatflt
latex floatflt.ins
cp floatflt.sty ${floatStyName} && texhash
",
  }


  exec {$floatStyName:
    command => $cmdFile,
    creates => $floatStyName,
    cwd => $downloadDir,
    path => '/usr/bin:/bin',
    require => [File[$cmdFile],
		Exec[$destZip],
		# Class['elexis::download_floatflt'],
		Package['unzip', 'texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']],
  }
}