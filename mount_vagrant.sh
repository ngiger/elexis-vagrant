#/bin/bash -v
fusermount -u /mnt/vagrant
echo "Default password for vagrant is vagrant"
sshfs -o reconnect -o gid=151 -o idmap=user -o allow_other -o umask=0113 -o follow_symlinks  vagrant@192.168.2.114:/home/vagrant /mnt/vagrant