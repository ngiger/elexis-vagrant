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
mod 'puppetlabs/postgresql', '3.1'
mod 'ripienaar/concat'
mod "puppetlabs/vcsrepo"
mod "maestrodev/rvm"
mod "thomasvandoren/etckeeper"
mod 'domcleal/augeasproviders'

mod "mthibaut/users" # has a travis.yml and specs

# mod 'ashleygould/sshauth', :git => 'https://github.com/ashleygould/puppet-sshauth.git'
# mod 'vurbia/sshauth', :git => 'https://github.com/vurbia/puppet-sshauth.git'
# mod 'boklm/sshauth', :git => 'https://github.com/boklm/puppet-sshkeys.git'

# mod 'lukas/ssh_authorized_key', :git => 'https://github.com/lukas-hetzenecker/puppet-module-ssh_authorized_key'
mod 'thias/resolvconf'
mod 'erwbgy/ssh'

# Module mit patches von mir.
mod 'ajjahn/samba',   :git => 'git://github.com/ngiger/puppet-samba.git'
#mod 'ajjahn/samba',   :path => 'puppet-samba'
 
# jenkins forked from https://github.com/rtyler/puppet-jenkins
mod "jenkins",    :git => "git://github.com/ngiger/puppet-jenkins.git"

# Eigene module von mir
mod "ngiger/x2go", '>=0.1.3', :git => 'git://github.com/ngiger/puppet-x2go.git'
mod 'ngiger/luks_backup', :git => 'https://github.com/ngiger/puppet-luks_backup.git'
mod 'ngiger/dnsmasqplus',  :git => 'https://github.com/ngiger/puppet-dnsmasqplus.git'
# mod 'ngiger/dnsmasqplus',  :path => 'puppet-dnsmasqplus'

# Lokale, nicht echte Module von mir
mod 'apache',     :path => './static-modules/apache'
mod 'cockpit',    :path => './static-modules/cockpit'
mod 'eclipse',    :path => './static-modules/eclipse'
mod 'elexis',     :path => './static-modules/elexis'
mod 'java',       :path => './static-modules/java'
mod 'jubula',     :path => './static-modules/jubula'
mod 'kde',        :path => './static-modules/kde'
mod 'ntp_demo',   :path => './static-modules/ntp_demo'
mod 'util',       :path => './static-modules/util'
