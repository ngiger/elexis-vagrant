
define eclipse::install_plugin(
  $pluginURL,
  $installIUs,
  $unlessFile,
  $eclipse_root = '/usr/lib/eclipse',
 ) {
  $fullName = "$eclipse_root/$unlessFile"
  $cmd = "${eclipse_root}/eclipse -application org.eclipse.equinox.p2.director -noSplash -repository $pluginURL -installIUs $installIUs"
  exec { "$pluginURL/${name}":
    command => $cmd,
    cwd => $eclipse_root,
    unless => "/usr/bin/test -f $fullName",
    require => File[$eclipse_root],
    path => '/usr/bin:/bin',
  }
}
