# Here we define a install various utilities for the administrator


class elexis::admin (
  $pg_util_rb = '/usr/local/bin/pg_util.rb'
)
inherits elexis::common {

  # The config writer personal choice
  if hiera('editor::default', false) {
    $editor_default = hiera('editor::default', '/usr/bin/vim.nox')  
    $editor_package = hiera('editor::package', 'vim-nox')
    package{ [ $editor_package ]: ensure => present, }
    
    exec {'set_default_editor':
      command => "update-alternatives --set editor ${editor_default}",
      require => Package[$editor_package],
      path    => "/usr/bin:/usr/sbin:/bin:/sbin",
      environment => 'LANG=C',
      unless  => "update-alternatives --display editor --quiet | grep currently | grep ${editor_default}"
    }  
  }
  
  exec {'set_timezone_zurich':
    command => "echo 'Europe/Zurich' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    environment => 'LANG=C',
    unless  => "grep Europe/Zurich /etc/timezone"
  } 

  # needed to install via elexis-cockpit
  $installBase = 'dummy'
  file {'/etc/auto_install_elexis.xml':
    content => template('elexis/auto_install.xml.erb'),
    mode  => 0644,
  }
  # --- done patching module apt
    
  # etckeeper is a nice utility which will track (each day or for each apt-get run) the changes
  # in the /etc directory. Handy to know why suddenly a package does not work anymore!
  include etckeeper
  ensure_packages['git', 'unzip', 'dlocate', 'mlocate', 'htop', 'curl', 'bzr', 'unattended-upgrades', 'fish', 'mosh']

  file {'/etc/apt/apt.conf.d/50unattended-upgrades':
    content => template('elexis/unattended_upgrades.erb'),
    owner => root,
    group => root,
    mode => 0644,
  }

  file {"$pg_util_rb":
    ensure => present,
    mode   => 0755,
    content => template("elexis/pg_util.rb.erb"),
  }
   
  # we migth use https://forge.puppetlabs.com/rendhalver/sudo to manage
  # permissions for these commands
  file { '/usr/local/bin/reboot.sh': 
    content => "sudo /sbin/shutdown -r -t 30 now\n",
    owner => root,
    group => 'elexis',
    mode => 6554,
    require => User['elexis'],
  }
  
  file { '/usr/local/bin/halt.sh': 
    content => "sudo /sbin/shutdown -h -t 30\n",
    owner => root,
    group => 'elexis',
    require => User['elexis'],
    mode => 6554,
  }
}
