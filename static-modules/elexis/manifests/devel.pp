# Here we define a few packages which are common to all elexis instances

class elexis::devel inherits elexis::common {
  include elexis::admin
  include elexis::client
  include elexis::mysql_server
  include elexis::postgresql_server
  include eclipse
  include jenkins
  include elexis::jenkins_commons
#  elexis::jenkins_elexis{'2.1.6': branch => '2.1.6'} # Adds Jenkins and jubula tests for Elexis 2.1.6
  elexis::jenkins_elexis{'2.1.7': branch => '2.1.7'} # Adds Jenkins and jubula tests for Elexis 2.1.6

}
