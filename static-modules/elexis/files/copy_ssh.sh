#!/bin/bash -v
user=$1
if [ -z $1 ] ; then exit 1; fi
export destination=`grep $user /etc/passwd | cut -d':' -f6`/.ssh
if [ $? -ne 0 ] ; then exit 1; fi
mkdir -p $destination/ && \
if [ -f ${destination}/id_rsa_elexis ] ; then exit 0 ; fi

if [ -f /etc/puppet/hieradata/private/$user/id_rsa ] ; 
then origin=/etc/puppet/hieradata/private/$user/
else origin=/etc/puppet/hieradata/$user/
fi
# echo origin ist $origin to copy to $destination
/bin/cp -v $origin/id_rsa     ${destination}/id_rsa_elexis && \
/bin/cp -v $origin/id_rsa.pub ${destination}/id_rsa_elexis.pub && \
/bin/chown -R $user:$user $destination/
