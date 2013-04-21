include eclipse

eclipse::install_plugin { 'wdev91.eclipse.copyright':
  pluginURL => 'http://www.wdev91.com/update/',
  installIUs => 'com.wdev91.eclipse.copyright',
  unlessFile => 'plugins/com.wdev91.eclipse.copyright_*.jar',
}

eclipse::install_plugin {'org.eclipse.egit.feature.group':
  pluginURL => 'http://download.eclipse.org/releases/juno',
  installIUs => 'org.eclipse.egit.feature.group',
  unlessFile => 'plugins/org.eclipse.mylyn.wikitext.core_*.jar',
}

eclipse::install_plugin { 'de.guhsoft.jinto.ui,de.guhsoft.jinto.core,de.guhsoft.jinto.doc':
  pluginURL => 'http://www.guh-software.de/eclipse/',
  installIUs => 'de.guhsoft.jinto.ui,de.guhsoft.jinto.core,de.guhsoft.jinto.doc',
  unlessFile => 'plugins/de.guhsoft.jinto.ui_*.jar',
}

eclipse::install_plugin {'com.vectrace.MercurialEclipse':
  pluginURL => 'http://mercurialeclipse.eclipselabs.org.codespot.com/hg.wiki/update_site/stable/',
  installIUs => 'com.vectrace.MercurialEclipse',
  unlessFile => 'plugins/com.vectrace.MercurialEclipse_*.jar',
}

