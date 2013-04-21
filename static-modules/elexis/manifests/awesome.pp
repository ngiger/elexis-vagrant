# Here we define a install various utilities for the awesome


class elexis::awesome inherits elexis::common {

  # we need x-display-manager, e.g. slim
  # an x-window-manager, e.g. awesome
  # demoDB is not getting installed!

  if !defined(Package['slim']) { package {'slim': } }
  if !defined(Package['awesome']) { package {'awesome': } }
  package{'xserver-xorg': }
  
  if !defined(Service['slim']) { 
  service { 'slim':
    ensure  => running,
    require => Package['slim', 'awesome', 'xserver-xorg'],
    }
  }
}
