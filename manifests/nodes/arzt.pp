node 'arzt' {
    # Default values can be overridden by setting value in your private/config.yaml

    # This medical doctor uses KDE as his/her GUI
    if hiera('kde:included', true)               { include kde }
    
    # She/he uses the OpenSource Elexis client
    if hiera('elexis::client:included', true)    { include elexis::client }
    
    # She/he has a local copy of the Elexis database on his system, which serves
    # as fallback if the main server is down
    if hiera('elexis::server:included', true)    { include elexis::server }
    
    # When at home She/he uses x2go to connect to the practice server
    if hiera('x2go::client:included', true)      { include x2go::client }

    # She/he wants to write letters and browse the internet
    if hiera('elexis::libreoffice:included', true)    { include elexis::libreoffice }
    if hiera('elexis::firefox:included', true)    { include elexis::firefox }
}
