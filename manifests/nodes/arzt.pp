node 'arzt' {
	# Default values can be overridden by setting value in your private/config.yaml
	
	# This medical doctor uses KDE as his/her GUI
	# kde { "kde-env": ensure => hiera('kde::ensure', true) }
	
	# She/he uses the OpenSource Elexis client
	# elexis::client {"elexis-client": ensure => hiera('elexis::client::ensure', true) }
	
	# She/he has a local copy of the Elexis database on his system, which serves
	# as fallback if the main server is down
	# elexis::mysql_server{ "mysql-server:": ensure => hiera('elexis::mysql_server::ensure', true) }
	
	# When at home She/he uses x2go to connect to the practice server
	x2go::client {"x2go-client": ensure => hiera('x2go::client::ensure', true) }
	  
    # She/he wants to write letters and browse the internet
    # elexis::libreoffice {'loffice': ensure => hiera('elexis::libreoffice::ensure', true) }
	# elexis::firefox {'firefox': ensure => hiera('elexis::firefox::ensure', true) }
}
