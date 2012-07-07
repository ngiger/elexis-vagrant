notify { "default.pp for vagrant/elexis": }

notify { "lsb $lsbdistcodename": }
# import "site.pp"