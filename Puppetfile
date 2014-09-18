# Configuration for librarian-puppet. For example:
# 
#forge 'https://forge.puppetlabs.com'
forge 'https://forgeapi.puppetlabs.com'

FORCE_FORGE ||= ENV['FORCE_FORGE']
puts "FORCE_FORGE ist #{FORCE_FORGE}"
def localOrRemote(name, path)
  if File.directory?(path) and not FORCE_FORGE
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


mod 'domcleal/augeasproviders'
mod "puppetlabs/stdlib"
mod 'jbeard/portmap'
mod 'jbeard/nfs'
mod "mthibaut/users" # has a travis.yml and specs
mod "puppetlabs/mysql"
mod 'puppetlabs/postgresql'
mod 'ripienaar/concat'
mod "thomasvandoren/etckeeper"
mod 'puppetlabs/apache'
mod 'erwbgy/ssh'
mod 'puppetlabs/java'
mod "puppetlabs/apt"
mod "puppetlabs/git"
mod 'puppetlabs/vcsrepo'
mod 'jdowning/rbenv'
mod 'jbussdieker/daemontools'

localOrRemote("ngiger/hylafax",     'puppet-hylafax')
localOrRemote("ngiger/cockpit",     'puppet-cockpit')
localOrRemote("ngiger/desktop",     'puppet-desktop')
localOrRemote("ngiger/dnsmasq",     'puppet-dnsmasq')
localOrRemote("ngiger/elexis",      'puppet-elexis')
localOrRemote("ngiger/hinmail",     'puppet-hinmail')
localOrRemote("ngiger/luks_backup", 'puppet-luks_backup')
localOrRemote("ngiger/x2go",        'puppet-x2go')
