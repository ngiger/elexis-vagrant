# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }

class ddb_org::oddb_git 
# inherits elexis::common 
{
#  $initFile =  '/etc/init.d/cockpit'
  $vcsRoot = '/var/www/oddb.org'
  package { ['make', 'libxslt*-dev', 'libxml2-dev']:
    ensure => installed,
  }
  
  package{  ['hiera',
    ]:
    ensure => present,
    provider => gem,
#    require => Package['make', 'libxslt*-dev', 'libxml2-dev'],
  }

#  file  { $initFile:
#    content => template('elexis/cockpit.init.erb'),
#    owner => 'root',
#    group => 'root',
#    mode  => 0754,
#  }
  
  if !defined(User['apache']) {
    user{'apache'}
  }
  if !defined(Group['apache']) {
    group{'apache'}
  }
  vcsrepo {  "$vcsRoot":
      ensure => present,
      provider => git,
      owner => 'apache',
      group => 'apache',
      source => "git://scm.ywesee.com/oddb.org/.git ",
      require => [User['apache'],],
  }
  
#  exec { 'bundle_trust_cockpit':
#    command => "rvm rvmrc trust $vcsRoot \
#    && cd $vcsRoot && pwd  && rvm list >trust.log \
#    && rvm all do bundle install --gemfile=Gemfile.ruby_1_9_2 --without test 2>&1| tee install.log",
#    creates => "$vcsRoot/trust.log",
#    cwd => "/usr/bin",
#    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
#    require => [ Package['bundler'], Vcsrepo[$vcsRoot], ],
#  }
}

#class elexis::cockpit_service inherits elexis::cockpit {
#  service { 'cockpit':
#    ensure => running,
#    enable => true,
#    hasstatus => false,
#    hasrestart => false,
#  }
#}

# class {'oddb_org::oddb_git_service':}
