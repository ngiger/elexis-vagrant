# Configuration for librarian-puppet. For example:
# 
# forge "http://forge.puppetlabs.com"
# 
# mod "puppetlabs/razor"
# mod "puppetlabs/ntp", "0.0.3"
# 
# mod "apt",
#   :git => "git://github.com/puppetlabs/puppetlabs-apt.git"
# 
# mod "stdlib",
#   :git => "git://github.com/puppetlabs/puppetlabs-stdlib.git"

forge "http://forge.puppetlabs.com"
# puppetlabs/postgresql provokes rubygems/requirement.rb:81:in `parse': Illformed requirement [">=1.1.0 <2.0.0"] (ArgumentError)
# mod "puppetlabs/postgresql" #, :git => 'git://github.com/puppetlabs/puppet-postgresql.git'
# instead use manually
# puppet module install --modulepath modules puppetlabs/postgresql 
mod "puppetlabs/apt"
mod "puppetlabs/mysql"
mod 'puppetlabs/firewall'
mod 'ripienaar/concat'
mod "puppetlabs/vcsrepo"
mod "maestrodev/rvm"
mod "rtyler/jenkins"
mod "thomasvandoren/etckeeper"
mod "ngiger/x2go", :git => 'git://github.com/ngiger/puppet-x2go.git'
mod "jenkins",    :git => "git://github.com/ngiger/puppet-jenkins.git"
mod 'elexis',     :path => './static-modules/elexis'

