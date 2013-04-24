class { 'elexis':
  $jenkinsRoot = '/srv/jenkins'
}

include elexis::jenkins_slave

