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
  $java                = 'openjdk-6-jdk',
  $eclipse             = 'eclipse-rcp-juno-linux-gtk-x86_64',
  $db_type             =  'mysql', # mysql or pg for postgresql
  $db_main             =  hiera('::db::main', 'elexis'), # Name of DB to use for production
  $db_test             =  'elexis', # DB to use for tests
  $db_user             =  'elexis', # DB-User to access both DB
  $db_password         =  'elexisTest', # a convention, which should be overridden somewhere!!!
  $backup_dir          =  '/opt/backup', # where we will put our backups
  $download_dir        =  '/opt/downloads',
  $bin_dir             =  '/usr/local/bin', # where we will put our binary helper scripts
  $downloadURL         =  'http://ftp.medelexis.ch/downloads_opensource'
) {
}