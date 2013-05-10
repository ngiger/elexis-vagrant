notify { "default.pp for vagrant/elexis": }

notify { "lsb $lsbdistcodename": }
# import "site.pp"

if !defined(File['/etc/system_role']) {
  file{'/etc/system_role': content => "# neither server nor backup\n" }
}
