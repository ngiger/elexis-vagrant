# Here we define a few packages which are common to all elexis instances

class elexis::devel inherits elexis::common {
  include elexis::admin
  include elexis::client
  include elexis::mysql_server
  include elexis::postgresql_server
  include jenkins
  include elexis::jenkins_commons
}
