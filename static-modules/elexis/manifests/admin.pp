# Here we define a install various utilities for the administrator


class elexis::admin inherits elexis::common {
  
  # The config writer personal choice
  if hiera('editor::default', false) {
    $editor_default = hiera('editor::default', '/usr/bin/vim.nox')  
    $editor_package = hiera('editor::package', 'vim-nox')
    package{ [ $editor_package ]: ensure => present, }
    
    exec {'set_default_editor':
      command => "update-alternatives --set editor ${editor_default}",
      require => Package[$editor_package],
      path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    }  
  }
  
  file { '/etc/timezone': 
    content => "Europe/Zurich\n",
  }
  
  # needed to install via elexis-cockpit
  $installBase = 'dummy'
  file {'/etc/auto_install_elexis.xml':
    content => template('elexis/auto_install.xml.erb'),
    mode  => 0644,
  }
    
  package{'htop':}
  
  # we migth use https://forge.puppetlabs.com/rendhalver/sudo to manage
  # permissions for these commands
  file { '/usr/local/bin/reboot.sh': 
    content => "sudo /sbin/shutdown -r -t 30 now\n",
    owner => root,
    group => 'elexis',
    mode => 6554,
  }
  
  file { '/usr/local/bin/halt.sh': 
    content => "sudo /sbin/shutdown -h -t 30\n",
    owner => root,
    group => 'elexis',
    mode => 6554,
  }
}
