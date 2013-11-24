# Here we define a install the desired Elexis version
# in a server location

# old versions
# $version = '2.1.6.4.1'
# $url = 'http://srv.elexis.info/jenkins/view/2.1.6/job/elexis-2.1.6-opensource/172/artifact/deploy/elexis-linux.x86_64-2.1.6.4.1.20131115-install.jar'

class elexis::app($version = '2.1.7.1',
  $url = 'http://srv.elexis.info/jenkins/view/2.1.7/job/elexis-2.1.7-Buildr-OpenSource/259/artifact/deploy/elexis-2.1.7.120131114-installer.jar
  $root = '/usr/local/elexis')
 inherits elexis::common {

# install elexis from the download site, either the deb or via install # TODO:
}
