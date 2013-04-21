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

mod "puppetlabs/apt"
mod "puppetlabs/mysql"
# mod 'puppetlabs/firewall'
mod 'puppetlabs/postgresql'
mod 'ripienaar/concat'
mod "puppetlabs/vcsrepo"
mod "maestrodev/rvm"
mod "thomasvandoren/etckeeper"

# Module mit patches von mir.
mod 'ajjahn/samba',   :git => 'git://github.com/ngiger/puppet-samba.git'

# jenkins forked from https://github.com/rtyler/puppet-jenkins
mod "jenkins",    :git => "git://github.com/ngiger/puppet-jenkins.git"

# Eigene module von mir
mod "ngiger/x2go", :git => 'git://github.com/ngiger/puppet-x2go.git'

# Lokale, nicht echte Module von mir
mod 'apache',     :path => './static-modules/apache'
mod 'buildr',     :path => './static-modules/buildr'
mod 'cockpit',    :path => './static-modules/cockpit'
mod 'eclipse',    :path => './static-modules/eclipse'
mod 'elexis',     :path => './static-modules/elexis'
mod 'java',       :path => './static-modules/java'
mod 'jubula',     :path => './static-modules/jubula'
mod 'kde',        :path => './static-modules/kde'
mod 'ntp_demo',   :path => './static-modules/ntp_demo'
mod 'sshd',       :path => './static-modules/sshd'
mod 'util',       :path => './static-modules/util'
