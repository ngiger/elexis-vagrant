# Here we define a install the desired Elexis version
# in a server location

class elexis::app($version = '2.1.6',
  $url = 'http://ngiger.dyndns.org/jenkins/view/2.1.6/job/Elexis-2.1.6-Buildr/154/artifact/src/deploy/elexis-2.1.6.99-installer.jar',
  $root = '/usr/local/elexis')
 inherits elexis::common {

# install elexis from the download site, either the deb or via install # TODO:
}
