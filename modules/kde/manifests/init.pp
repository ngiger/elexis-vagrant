class kde {
    package{
	[ # 'task-german-kde-desktop', # exists only under Debian
	'kde-plasma-desktop', # KDE Plasma Desktop and minimal set of applications
	'kde-standard',	# KDE Plasma Desktop and standard set of applications
	'kdm',
	'kde-l10n-de',
#	'manpages-de', 'hyphen-de' task-german
	# for debian 'task-german-kde-desktop',
	#  language-pack-kde-de language-pack-kde-de-base
      ]:
      ensure => present,
    }
}
