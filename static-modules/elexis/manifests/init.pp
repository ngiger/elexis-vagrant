# == Class: elexis
#
# This is a base class that can be used to modify catalog-wide settings relating
# to the various types in class contained in the elexis module.
#
# If you don't declare this class in your catalog, sensible defaults will
# be used.  However, if you choose to declare it, it needs to appear *before*
# any other types or classes from the elexis module.
#
# For examples, see the files in the `tests` directory; in particular,
# `/pg_server.pp`.
#
#
# [*java*]
#    The java version to install. If not specified, the
#    module will use whatever version is the default for your
#    OS distro.
#
# [*eclipse*]
#    The eclipse version to install. If not specified, the
#    module will use whatever version is the default for your
#    OS distro. Otherwise it will download it from the medelexis-Opensource
#    and install a link into the /usr/local/bin
#
# === Examples:
#
#   class { 'elexis':
#     java               => 'openjdk-6,
#     eclipse            => 'juno-rcp-SR2',
#   }
#
#

class elexis (
  $db_type             =  hiera('elexis::db_type', 'mysql'),           # mysql or pg for postgresql
  $db_main             =  hiera('elexis::db_main', 'elexis'),          # Name of DB to use for production
  $db_test             =  hiera('elexis::db_test', 'test'),            # Name of test DB to use for production
  $db_password         =  hiera('elexis::db_password', 'elexisTest'),  # password of main DB user
  $db_pw_hash          =  hiera('elexis::db_pw_hash', ''),             # or better and used if present password hash of main DB user
  
  $java                = hiera('elexis::java_version',      'openjdk-6-jdk'),
  $binDir              = hiera('elexis::bin_dir',           '/usr/local/bin'),          # where we will put our binary helper scripts
  $service_path         = hiera('elexis::service',          '/var/lib/service'),
  $jenkinsRoot          = hiera('elexis::jenkinsDir',       '/opt/jenkins'),
  $eclipseRelease       = hiera('elexis::eclipseRelease',   'juno'),
  $defaultEclipse       = hiera('elexis::default_eclipse',  'eclipse-rcp-juno-SR2'),
  $downloadDir          = hiera('elexis::downloadDir',      '/opt/downloads'),
  $downloadURL          = hiera('elexis::downloadURL',      'http://ftp.medelexis.ch/downloads_opensource'),
  $jenkinsRoot          = hiera('elexis::jenkinsRoot',      '/opt/jenkins'),
  $jenkinsDownloads     = hiera('elexis::jenkinsDownloads', '/opt/jenkins/downloads'),
  $jenkinsJobsDir       = hiera('elexis::jenkinsJobsDir',   '/opt/jenkins/jobs'),
  $elexisBaseURL        = hiera('elexis::elexisBaseURL',    'http://hg.sourceforge.net/hgweb/elexis')
) {
  # notify{"elexis with java $java downloadURL $downloadURL ":}
  # class java($version = 6, $variant = 'openjdk', $hasJdk = false, $hasJre = true ) {
  class { 'java':
    version => 7,
    variant => 'openjdk', # sun gibt es ab Debian Wheezy nicht mehr!
    hasJdk => true,
    hasJre => true,
  }
  
}
