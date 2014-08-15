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


class elexis::params (
  $create_service_script  = "${elexis::binDir}/create_service.rb",
  $destZip                = "$elexis::downloadDir/floatflt.zip",
  $elexisFileServer       = "http://ftp.medelexis.ch/downloads_opensource",
) inherits elexis {
}

