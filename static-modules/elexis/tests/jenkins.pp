notify {"elexis::tests::jenkins":}
include jenkins
include elexis::jenkins_commons 
# elexis::jenkins_elexis{'2.1.6': }
elexis::jenkins_elexis{'2.1.7': }

