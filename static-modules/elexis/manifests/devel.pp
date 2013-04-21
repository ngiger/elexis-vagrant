# Here we define a few packages which are common to all elexis instances

class elexis::devel inherits elexis::common {

  include elexis::client
  include elexis::mysql_server
  include eclipse
  include jenkins
  include elexis::jenkins_commons
  elexis::jenkins_elexis{'2.1.6': branch => '2.1.6'} # Adds Jenkins and jubula tests for Elexis 2.1.6

#  include elexis::jenkins_2_2_dev_jpa # TODO: Zweite Priorität , dito 2.1.6/zdavatz and buildr)
#  include buildr # TODO: Dritte Priorität, da mit 2.1.7 mit ant gebuildet werden kann
}
