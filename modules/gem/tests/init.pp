# gem('net-ldap', install, nil, "--no-rdoc --no-ri")
# gem('json', absent)

# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# This test will alternatively install/uninstall the gem modules json and net-ldap

$ldapIsPresent = gemIsInstalled('net-ldap')

case $ldapIsPresent {
  false: {
      notify { "will install net-ldap": }
      gem('net-ldap', 'present', '0.3.1', "--no-rdoc --no-ri")
      gem('json', 'install')
  }
  true: {
      notify { "will uninstall net-ldap:": }
      gem('net-ldap', absent, '0.3.1', "--no-rdoc --no-ri")
      gem('json', uninstall)
  }
}