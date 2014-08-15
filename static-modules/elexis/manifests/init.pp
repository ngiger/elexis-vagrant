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
#
# === Examples:
#
#   class { 'elexis':
#     java               => 'openjdk-6,
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
  $downloadDir          = hiera('elexis::downloadDir',      '/opt/downloads'),
  $downloadURL          = hiera('elexis::downloadURL',      'http://ftp.medelexis.ch/downloads_opensource'),
  $jenkinsRoot          = hiera('elexis::jenkinsRoot',      '/opt/jenkins'),
  $jenkinsDownloads     = hiera('elexis::jenkinsDownloads', '/opt/jenkins/downloads'),
  $jenkinsJobsDir       = hiera('elexis::jenkinsJobsDir',   '/opt/jenkins/jobs'),
  $elexisBaseURL        = hiera('elexis::elexisBaseURL',    'http://hg.sourceforge.net/hgweb/elexis')
) {

define setdefault_acl(
  $default_acl = "",
  $path        = "",
       ) {
    ensure_packages['acl']
    exec{"set default_acl for $path":
      command => "/usr/bin/setfacl -dm $default_acl $path",
      onlyif  => "/usr/bin/test -e $path",
    }
}

	file { '/usr/local/bin/set_default_facl':
		mode => 0744,
		content => template('elexis/set_default_facl.erb'),
		}
}
