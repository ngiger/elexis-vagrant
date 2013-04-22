# Install various plugins commonly used by Elexis developers
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

require jenkins
require elexis::common


define elexis::eclipse_plugins(
  $instDir = "/opt/eclipse/${title}/eclipse",
  $desired_plugins = 'copyright,egit,jinto,MercurialEclipse,wikitext,',
) {

  Eclipse::Install_plugin {
    eclipse_root => $instDir,
    require => [ Class['Java'], File[$instDir] ],
  }
  case $desired_plugins {
    /copyright/ : {
	eclipse::install_plugin { 'wdev91.eclipse.copyright':
	  pluginURL => 'http://www.wdev91.com/update/',
	  installIUs => 'com.wdev91.eclipse.copyright',
	  unlessFile => 'plugins/com.wdev91.eclipse.copyright_*.jar',
	}
      }
    default: { notify{"skip copyright plugin for ${instDir}": } }
  }

  case $desired_plugins {
    /egit/ : {
        eclipse::install_plugin {'org.eclipse.egit.feature.group':
          pluginURL => "http://download.eclipse.org/releases/$eclipseRelease",
          installIUs => 'org.eclipse.egit.feature.group',
          unlessFile => 'plugins/org.eclipse.egit_*.jar',
        }
      }
    default: { notify{"skip egit plugin for ${instDir}": } }
  }

  case $desired_plugins {
    /jinto/ : {
	eclipse::install_plugin { 'de.guhsoft.jinto.ui,de.guhsoft.jinto.core,de.guhsoft.jinto.doc':
	  pluginURL => 'http://www.guh-software.de/eclipse/',
	  installIUs => 'de.guhsoft.jinto.ui,de.guhsoft.jinto.core,de.guhsoft.jinto.doc',
	  unlessFile => 'plugins/de.guhsoft.jinto.ui_*.jar',
	}
      }
    default: { notify{"skip jinto plugin for ${instDir}": } }
  }

  case $desired_plugins {
    /MercurialEclipse/ : {
	eclipse::install_plugin {'com.vectrace.MercurialEclipse':
	  pluginURL => 'http://mercurialeclipse.eclipselabs.org.codespot.com/hg.wiki/update_site/stable/',
	  installIUs => 'com.vectrace.MercurialEclipse',
	  unlessFile => 'plugins/com.vectrace.MercurialEclipse_*.jar',
	}
      }
    default: { notify{"skip MercurialEclipse plugin for ${instDir}": } }
  }

  case $desired_plugins {
    /wikitext/ : {
    eclipse::install_plugin {'org.eclipse.wikitext.feature.group':
      pluginURL => "http://download.eclipse.org/releases/$eclipseRelease",
      installIUs => 'org.eclipse.wikitext.feature.group',
      unlessFile => 'plugins/org.eclipse.mylyn.wikitext.core_*.jar',
      }
    }
    default: { notify{"skip MercurialEclipse plugin for ${instDir}": } }
  }

# TODO: Fix this plugin
#   case $desired_plugins {
#      /tapiji/ : {
#      # needs first jsf JavaServerFace 
#      eclipse::install_plugin {'org.eclipse.jsf.feature.feature.group':
#        pluginURL => "http://download.eclipse.org/releases/$eclipseRelease",
#        installIUs => 'org.eclipse.jsf.feature.feature.group',
#        unlessFile => 'plugins/org.eclipse.jsf*jar',
#      }
#      
#      eclipse::install_plugin {'org.eclipselabs.tapiji.tools.feature.feature.group':
#        pluginURL => "http://svn.codespot.com/a/eclipselabs.org/tapiji/update",
#        installIUs => 'org.eclipselabs.tapiji.tools.feature.feature.group',
#        unlessFile => 'plugins/org.eclipselabs.tapiji.tools.java*.jar',
#        require => Eclipse::Install_plugin['org.eclipse.jsf.feature.feature.group'],
#      }
#     }
#     default: { notify{"skip wikitext plugin for ${instDir}": } }
#   }
# 	
}
