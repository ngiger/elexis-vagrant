node 'mpa' {
    # Default values can be overridden by setting value in your private/config.yaml

    # This medical assistant uses KDE as his/her GUI
    if hiera('kde::ensure', true)               { include kde }
    
    # She/he uses the OpenSource Elexis client
    if hiera('elexis::client::ensure', true)    { include elexis::client }
    
    # She/he wants to write letters and browse the internet
    if hiera('elexis::libreoffice::ensure', true)    { include elexis::libreoffice }
    if hiera('elexis::firefox::ensure', true)    { include elexis::firefox }

}
