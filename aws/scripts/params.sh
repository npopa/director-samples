#!/bin/bash

##### Various parameters 

rm -rf /tmp/params.sh
touch /tmp/params.sh
chmod 755 /tmp/params.sh
chown root:root /tmp/params.sh

cat <<-\EOF >/tmp/params.sh
#This file is generated and should be removed at the end of the install autmatically

source /tmp/secrets.sh
#The below env variables are already defined in the secrets.sh
export DEFAULT_PASSWORD=$DEFAULT_PASSWORD

#Java install
#jdk1.7.0_80 - http://download.oracle.com/otn/java/jdk/7u80-b15/jdk-7u80-linux-x64.rpm
export ORACLE_COOKIE='Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie'
JDK_1_8_121_DOWNLOAD_URL="http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.rpm"
JDK_1_8_131_DOWNLOAD_URL="http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
JCE8_DOWNLOAD_URL="http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"

export JAVA_VERSION='jdk1.8.0_131'
if [[ $JAVA_VERSION == 'jdk1.8.0_131' ]]; then 
    export JAVA_DOWNLOAD_URL="${JDK_1_8_131_DOWNLOAD_URL} "
    export JCE_DOWNLOAD_URL="${JCE8_DOWNLOAD_URL}"
fi


export JAVA_HOME="/usr/java/${JAVA_VERSION}"
export PATH="$JAVA_HOME/bin:$PATH"


export MYSQL_CONNECTOR_URL="http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz"



#The below env variables are defined in this file
#this gets autoreplaced by the real director hostname
export DIRECTOR_HOST=AUTO_REPLACED 


#Kerberos
export DOMAIN_NAME="threeosix.lan"
export REALM_NAME=${DOMAIN_NAME^^}
export KDC_TYPE="MIT KDC"
export KDC_ADMIN_PASSWORD=$DEFAULT_PASSWORD
export KDC_HOST_NAME=${DIRECTOR_HOST} #assumes kdc runs on the same host as director
export KERBEROS_ADMIN_USER="scm/admin@${REALM_NAME}"
export KERBEROS_ADMIN_PASS=$DEFAULT_PASSWORD
export KRB_ENC_TYPES="aes256-cts arcfour-hmac"

#LDAP
export LDAP_HOST=${DIRECTOR_HOST} #assumes ldap runs on the same host as director
export LDAP_SUFFIX=`echo $DOMAIN_NAME|sed 's/\./,dc=/g'|sed 's/^/dc=/g'`
export LDAP_DC=`echo $DOMAIN_NAME|cut -d"." -f1`

#mysql
export MYSQL_ADMIN="root"
export MYSQL_ADMIN_PASS=$DEFAULT_PASSWORD
export MYSQL_HOST=${DIRECTOR_HOST}    #assumes mysql runs on the same host as director

#####mysql stuff 
export DB_TYPE="mysql"
export DB_IP=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')
export DB_HOST=$(hostname -f)
export DB_PORT='3306'
export DB_USER="root"
export DB_PASS="cloudera"


#Puppet
export PUPPET_HOST=${DIRECTOR_HOST}
export PUPPET_SSL_HOME=/etc/puppetlabs/puppet/ssl/

#SSL - there should be no need to change these
export CERT_OUTPUT_DIR="/opt/cloudera/security"
export CERT_KEY_PASS=$DEFAULT_PASSWORD

export JKS_KEYSTORE="${CERT_OUTPUT_DIR}/jks/keystore.jks"
export JKS_KEYSTORE_PASSWORD=$DEFAULT_PASSWORD
export JKS_TRUSTSTORE="${CERT_OUTPUT_DIR}/jks/truststore.jks"
export JKS_TRUSTSTORE_PASSWORD=$DEFAULT_PASSWORD

export PEM_KEY="${CERT_OUTPUT_DIR}/x509/key.pem"
export PEM_KEY_PASSWORD=$DEFAULT_PASSWORD
export PEM_KEY_NOPASSWORD="${CERT_OUTPUT_DIR}/x509/keynopw.pem"
export PEM_CERT="${CERT_OUTPUT_DIR}/x509/cert.pem"
export PEM_CACERT="${CERT_OUTPUT_DIR}/truststore/ca-truststore.pem"


EOF


