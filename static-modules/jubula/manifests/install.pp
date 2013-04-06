 # kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
class jubula::install inherits jubula {
  notify {'jubula::install': }
 #  installJubula($jubulaURL, $setupSh, $destDir, $scriptName)
}
class {'jubula::install':stage => last; }
