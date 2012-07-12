# Install a specific eclipse version, downloaded from a mirror
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

define eclipse::install(
  $eclipseVersion => 'indigo-SR2'
  $eclipseVariant => 'linux.x86_64'
  $eclipseURL => "http://ftp.medelexis.ch/downloads_opensource/eclipse/${eclipseVersion}-${eclipseVariant}"
  $targetBase => '/opt/eclipse'
) {
   notify { "Install eclipse ${eclipseVersio} from ${} into ${targetBase}": }
}