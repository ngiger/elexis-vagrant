# Configuration for librarian-puppet. For example:
# 
#forge "https://forge.puppetlabs.com"
forge 'https://forgeapi.puppetlabs.com'
#forge 'https://forgeapi.puppetlabs.com'
mod "puppetlabs/apt"

mod 'puppetlabs/apache'
# mod 'haraldsk/nfs', :git => 'https://github.com/haraldsk/puppet-module-nfs.git' # is not installable
# mod 'arusso/nfs'

# mod 'ghoneycutt/nfs'
mod 'jbeard/nfs' #, :git => 'https://github.com/jbeard6/jbeard-nfs'

mod "puppetlabs/mysql"
mod 'puppetlabs/postgresql'
mod 'ripienaar/concat'
mod 'domcleal/augeasproviders'
mod "mthibaut/users" # has a travis.yml and specs
mod "thomasvandoren/etckeeper"

# mod 'saz/resolv_conf'
mod 'erwbgy/ssh'
mod 'puppetlabs/java'

# Module mit patches von mir.
mod 'ajjahn/samba',   :git => 'git://github.com/ngiger/puppet-samba.git'


# Bis hierhin okay?

# Lokale, nicht echte Module von mir
def localOrRemote(name, path)
  if File.directory?(path) 
    mod(name, :path => path)
    savedDir = Dir.pwd
    if false
      Dir.chdir(path)
      system("git pull")
      Dir.chdir(savedDir)
    end
  else
    mod(name, :git => "https://github.com/ngiger/#{path}.git")
  end
end

localOrRemote("ngiger/cockpit",     'puppet-cockpit')
localOrRemote("ngiger/desktop",     'puppet-desktop')
localOrRemote("ngiger/dnsmasq",     'puppet-dnsmasq')
localOrRemote("ngiger/elexis",      'puppet-elexis')
localOrRemote("ngiger/luks_backup", 'puppet-luks_backup')
localOrRemote("ngiger/x2go",        'puppet-x2go')
