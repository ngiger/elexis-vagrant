# we need also an x-display-manager, e.g. slim
# an x-window-manager, e.g. awesome
# demoDB is not getting installed!

package {['slim', 'awesome']: }

if (false) {
  include elexis::install
  elexis::install {"elexis-Medelexis":
    programURL             => 'http://www.medelexis.ch/dl21.php?file=medelexis-linux',
    version                => 'current',
    installBase            => '/opt/elexis',
  }

} else {
  elexis::install  {"OpenSource":
    programURL             => hiera('elexis::install::OpenSource::programURL', 'please provide a correct URL'),
    version                => hiera('elexis::install::OpenSource::version',    'please provide a correct version'),
    installBase            => hiera('elexis::install::OpenSource::installBase', '/usr/local/elexis'),
  }
}

