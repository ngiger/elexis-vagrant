# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }
class elexis::cockpit inherits elexis::common {
  $initFile =  '/etc/init.d/cockpit'
  $vcsRoot = '/home/elexis/elexis-cockpit'
  package { ['make', 'libxslt*-dev', 'libxml2-dev']:
    ensure => installed,
  }
  
  package{  ['sinatra',
    'shotgun', 
    'hiera',
    'datamapper',
    'i18n_rails_helpers',
    'bundler',
    'sys-filesystem',
    'actionpack',
    'activesupport',
    'nokogiri',
    'RedCloth',
    ]:
    ensure => present,
    provider => gem,
    require => Package['make', 'libxslt*-dev', 'libxml2-dev'],
  }

  file  { $initFile:
    content => template('elexis/cockpit.init.erb'),
    owner => 'root',
    group => 'root',
    mode  => 0754,
  }
  
  vcsrepo {  "$vcsRoot":
      ensure => present,
      provider => git,
      owner => 'elexis',
      group => 'elexis',
      source => "https://github.com/elexis/elexis-cockpit.git",
      require => [User['elexis'],],
  }
  
  exec { 'bundle_trust_cockpit':
    command => "rvm rvmrc trust $vcsRoot \
    && cd $vcsRoot && pwd  && rvm list >trust.log \
    && rvm all do bundle install --gemfile=Gemfile.ruby_1_9_2 --without test 2>&1| tee install.log",
    creates => "$vcsRoot/trust.log",
    cwd => "/usr/bin",
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    require => [ Package['bundler'], Vcsrepo[$vcsRoot], ],
  }
}

class elexis::cockpit_service inherits elexis::cockpit {
  service { 'cockpit':
    ensure => running,
    enable => true,
    hasstatus => false,
    hasrestart => false,
  }
}

class {'elexis::cockpit_service':stage => deploy_app; }
