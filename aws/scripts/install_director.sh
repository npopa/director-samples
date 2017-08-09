#!/bin/bash

#### Install Director

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -z ${MYSQL_HOST} || -z ${MYSQL_ADMIN} || -z ${MYSQL_ADMIN_PASS} ]]; then 
	echo ' ${MYSQL_HOST}, ${MYSQL_ADMIN}, ${MYSQL_ADMIN_PASS} must be defined'
	exit 1
fi

wget "http://archive.cloudera.com/director/redhat/7/x86_64/director/cloudera-director.repo" -O /etc/yum.repos.d/cloudera-director.repo

yum -y install cloudera-director-server cloudera-director-client

export DIRECTOR_DB_TYPE="mysql"
export DIRECTOR_DB_NAME="director"
export DIRECTOR_DB_USER="director"
export DIRECTOR_DB_PASS=$DEFAULT_PASSWORD
export DIRECTOR_DB_PORT="3306"

###  Create the director database and director user.   ###
mysql -h ${MYSQL_HOST} -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASS} -e "CREATE DATABASE ${DIRECTOR_DB_NAME} DEFAULT CHARACTER SET utf8"
mysql -h ${MYSQL_HOST} -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASS} -e "GRANT ALL ON ${DIRECTOR_DB_NAME}.* TO '"${DIRECTOR_DB_USER}"'@'"${DIRECTOR_IP_ADDRESS}"' IDENTIFIED BY '"${DIRECTOR_DB_PASS}"' WITH GRANT OPTION"

DIRECTOR_PROPERTIES=$(mktemp -t director_properties.XXXXXXXXXX)

###  Configure Director Server to use mysql for Metadata Storage.  ###
sed -e "s/# lp.database.type: mysql/lp.database.type: ${DIRECTOR_DB_TYPE}/" \
 -e "s/# lp.database.username:/lp.database.username: ${DIRECTOR_DB_USER}/" \
 -e "s/# lp.database.password:/lp.database.password: ${DIRECTOR_DB_PASS}/" \
 -e "s/# lp.database.host:/lp.database.host: ${MYSQL_HOST}/" \
 -e "s/# lp.database.port:/lp.database.port: ${DIRECTOR_DB_PORT}/" \
 -e "s/# lp.database.name:/lp.database.name: ${DIRECTOR_DB_NAME}/" \
 /etc/cloudera-director-server/application.properties > "${DIRECTOR_PROPERTIES}"
cat "${DIRECTOR_PROPERTIES}" > /etc/cloudera-director-server/application.properties



###  Start Cloudera Director Server and Enable it on Startup  ###
systemctl start cloudera-director-server
systemctl enable cloudera-director-server



# nohup ssh -i "your-key-file.pem" -CND 8157 ec2-user@instance_running_director_server &
#"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --user-data-dir="$HOME/chrome-with-proxy" --proxy-server="socks5://localhost:8157"

