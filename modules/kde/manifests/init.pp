class kde {
    package{
	[ # 'task-german-kde-desktop', # exists only under Debian
	'kde-plasma-desktop', # KDE Plasma Desktop and minimal set of applications
	'kde-standard',	# KDE Plasma Desktop and standard set of applications
	'kdm',
      ]:
      ensure => present,
    }
}
