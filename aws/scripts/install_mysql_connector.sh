#!/bin/bash

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -z ${MYSQL_CONNECTOR_URL} ]]; then 
	echo ' ${MYSQL_CONNECTOR_URL} must be defined'
	exit 1
fi


if [[ -f /usr/share/java/mysql-connector-java-5.1.40-bin.jar ]]; then
	echo "mysql-connector-java-5.1.40 already installed. Skipping..."
else
	echo "Installing mysql-connector-java"
	
	MYSQL_CONNECTOR_FILE=${MYSQL_CONNECTOR_URL##*/}
	wget ${MYSQL_CONNECTOR_URL} -O /tmp/${MYSQL_CONNECTOR_FILE}
	mkdir -p /usr/share/java/
	tar xzvf /tmp/mysql-connector-java-5.1.40.tar.gz --no-anchored -C /usr/share/java/ --strip 1 mysql-connector-java-5.1.40-bin.jar
fi

#Create the link in any case
ln -sf /usr/share/java/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar


