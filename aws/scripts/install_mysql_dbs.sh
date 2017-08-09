#!/bin/bash

### Install mysql server

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -z ${MYSQL_ADMIN} || -z ${MYSQL_ADMIN_PASS} ]]; then 
	echo ' ${MYSQL_ADMIN}, ${MYSQL_ADMIN_PASS} must be defined'
	exit 1
fi


###  Define Variables  ###

for db in scm amon rman metastore sentry nav navms oozie hue; do 
mysql -u ${MYSQL_ADMIN} --password=${MYSQL_ADMIN_PASS} <<-ESQL
use mysql;

drop database if exists ${db};
create database ${db} DEFAULT CHARACTER SET utf8;
grant all on ${db}.* TO '${db}'@'%' IDENTIFIED BY '${db}' with grant option;

flush privileges;
ESQL

done


