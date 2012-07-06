notify { "default.pp for vagrant/elexis": }

user {'puppet':
  ensure => present,
}

notify { "lsb $lsbdistcodename": }
# import "site.pp"