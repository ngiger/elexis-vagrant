#!/bin/sh
#
# postgres-archive-command
# ************************
#
# Dieses Programm kopiert eine PostgreSQL WAL-Datei auf einen anderen Server.
#
#*-----------------------------------------------------------------------------
#
# copyright 2011 by Daniel Lutz
#
#*-----------------------------------------------------------------------------

# Aufruf:
# postgresql-archive-command %p %f <hostname> <target dir>

source_path=$1
file_name=$2
hostname=$3
target_dir=$4
progname=`basename ${0}`
scp_options="-o LogLevel=FATAL -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -i ${HOME}/.ssh/id_rsa_elexis"
if [ -z "${source_path}" -o -z "${file_name}" -o -z "${hostname}" -o -z "${target_dir}" ]; then
  msg = "ERROR: Aufruf: $0 %p %f hostname target_dir"
  echo $msg
  logger $msg
  exit 1
fi

ssh ${scp_options} ${hostname} test '!' -f "${target_dir}/${file_name}"
ret=$?

if [ "${ret}" != 0 ]; then
  # Datei existiert
  exit 1
fi

scp ${scp_options} "${source_path}" "${hostname}:${target_dir}/${file_name}"
ret=$?

if [ "${ret}" != 0 ]; then
  msg = "ERROR: while copying ${source_path} to ${hostname}:${target_dir}/${file_name}"
  echo $msg
  logger $msg
  exit 1
fi

msg = "$0: Done copying ${source_path} to ${hostname}:${target_dir}/${file_name}"
logger $msg
exit 0