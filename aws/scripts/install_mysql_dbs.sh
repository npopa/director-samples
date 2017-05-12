#!/bin/bash

### Install mysql server

. /tmp/params.sh

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


