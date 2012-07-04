node "ng-hp" {
    notify { "site.pp node ng-hp": }

    host { 'puppet':
      ensure => present,
      host_aliases => ['puppet', 'aptproxy','ng-hp'],
      ip => "$ipaddress_eth0",
      target => '/etc/hosts',
    }

    include x2go::server
    include elexis::jenkins_2_1_7
    include elexis::server
    include elexis::praxis_wiki

}

