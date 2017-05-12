#!/bin/bash


if [[ -f /usr/share/java/mysql-connector-java-5.1.40-bin.jar ]]; then
	echo "mysql-connector-java-5.1.40 already installed. Skipping."
else
	echo "Installing mysql-connector-java"
	wget "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz" -O /tmp/mysql-connector-java-5.1.40.tar.gz
	tar zxvf /tmp/mysql-connector-java-5.1.40.tar.gz -C /tmp/
	mkdir -p /usr/share/java/
	cp /tmp/mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /usr/share/java/
	rm /usr/share/java/mysql-connector-java.jar
	ln -s /usr/share/java/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar
fi

