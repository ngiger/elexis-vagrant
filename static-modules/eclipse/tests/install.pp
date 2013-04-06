include eclipse::install
eclipse::install{
  eclipseVersion => 'juno'
  eclipseVariant => 'linux.x86'
  eclipseURL => "http://mirror.switch.ch/eclipse/technology/epp/downloads/release/juno/R/${eclipseVersion}-${eclipseVariant}"
}
    eclipse::install('juno', 'http://mirror.switch.ch/eclipse/technology/epp/downloads/release/juno/R')
