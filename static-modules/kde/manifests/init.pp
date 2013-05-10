class kde {
  include apt
  
    package{
	[ # 'task-german-kde-desktop', # exists only under Debian
	'kde-plasma-desktop', # KDE Plasma Desktop and minimal set of applications
	# 'kde-standard',	# KDE Plasma Desktop and standard set of applications
	'kdm',
  'kate',
  'kontact',
  'krusader',
  'kde-l10n-de',
  'okular',
#	'manpages-de', 'hyphen-de' task-german
	# for debian 'task-german-kde-desktop',
	#  language-pack-kde-de language-pack-kde-de-base
      ]:
      ensure => present,
#       options => '--no-install-recommends',
#       options => norecommended,
#      require => [Class['apt::update']],
    }

  package { 'network-manager':
    ensure => absent,
  }
  service{'kdm': ensure => running, require => Package['kdm'], }
  
  $kde_config = '/etc/skel/.kde/share/config'
  $kde_apps   = '/etc/skel/.kde/share/apps'
  $kde_konsole = '/etc/skel/.kde/share/apps/konsole'
  exec {["$kde_config"]:
    command => "/bin/mkdir -p $kde_config",
    unless => "/usr/bin/test -d $kde_config",
  }            

  file {"$kde_config/kxkbrc":
    content => "[Layout]
DisplayNames=
LayoutList=ch
LayoutLoopCount=-1
Model=pc105
ResetOldOptions=false
ShowFlag=false
ShowLabel=true
ShowLayoutIndicator=true
ShowSingle=false
SwitchMode=Global
Use=true
",
    require => [ Exec[$kde_config]],
    mode  => 0644,
    }

  exec {["$kde_konsole"]:
    command => "/bin/mkdir -p $kde_konsole",
    unless => "/usr/bin/test -d $kde_konsole",
  }
  file {"$kde_konsole/Shell.profile":
    content => "[Appearance]
ColorScheme=BlackOnRandomLight

[General]
Icon=utilities-terminal
LocalTabTitleFormat=%D : %n
Name=Shell
Parent=FALLBACK/
RemoteTabTitleFormat=(%u) %H
ShowNewAndCloseTabButtons=true

[Terminal Features]
BidiRenderingEnabled=true
",
    require => [ Exec["$kde_konsole"]],
    mode  => 0644,
    }
}
