#!/bin/bash -v
echo "new password is $1"
sudo /etc/init.d/mysql stop && sleep 3
sudo mysqld_safe --skip-grant-tables &
sleep 3
mysql -u root -D mysql -e "update user set password=password('$1') where user='root'"
mysql -u root -e "flush privileges"
sudo killall mysqld_safe && sleep 3
sudo /etc/init.d/mysql start