#!/bin/bash

##### Various parameters 

rm -rf /tmp/params.sh
touch /tmp/params.sh
chmod 700 /tmp/params.sh
chown root:root /tmp/params.sh

cat <<-\EOF >/tmp/params.sh
#This file is generated and should be removed at the end of the install autmatically

. /tmp/secrets.sh

#The below env variables are already defined in the secrets.sh
export DEFAULT_PASSWORD=$DEFAULT_PASSWORD

#The below env variables are defined in this file
export DIRECTOR_HOST=ip-10-10-10-116.us-west-2.compute.internal

#Kerberos
export KDC_ADMIN_PASSWORD=$DEFAULT_PASSWORD
export CLUSTER_REALM="THREEOSIX.LAN"
export CLUSTER_DOMAIN="threeosix.lan"
export KDC_HOST=${DIRECTOR_HOST} #assumes kdc runs on the same host as director

#LDAP
export LDAP_HOST=${DIRECTOR_HOST} #assumes ldap runs on the same host as director
export LDAP_SUFFIX="dc=threeosix,dc=lan"
export LDAP_DC="threeosix"

#mysql
export MYSQL_ADMIN="root"
export MYSQL_ADMIN_PASS=$DEFAULT_PASSWORD

export MYSQL_IP=${DIRECTOR_HOST}    #assumes mysql runs on the same host as director
export DIRECTOR_DB_TYPE="mysql"
export DIRECTOR_DB_NAME="director"
export DIRECTOR_DB_USER="director"
export DIRECTOR_DB_PASS=$DEFAULT_PASSWORD
export DIRECTOR_DB_PORT="3306"

export PUPPET_HOST=${DIRECTOR_HOST}
export PUPPET_SSL_HOME=/etc/puppetlabs/puppet/ssl/

export CERT_OUTPUT_DIR=/opt/cloudera/security
export CERT_KEY_PASS=cloudera

export JAVA_HOME=/usr/java/jdk1.8.0_121
export PATH=$JAVA_HOME/bin:$PATH

#SSL
export JKS_KEYSTORE="/opt/cloudera/security/jks/keystore.jks"
export JKS_KEYSTORE_PASSWORD="cloudera"
export JKS_TRUSTSTORE="/opt/cloudera/security/jks/truststore.jks"
export JKS_TRUSTSTORE_PASSWORD="cloudera"

export PEM_KEY="/opt/cloudera/security/x509/key.pem"
export PEM_KEY_PASSWORD="cloudera"
export PEM_KEY_NOPASSWORD="/opt/cloudera/security/x509/keynopw.pem"
export PEM_CERT="/opt/cloudera/security/x509/cert.pem"
export PEM_CACERT="/opt/cloudera/security/truststore/ca-truststore.pem"


EOF


