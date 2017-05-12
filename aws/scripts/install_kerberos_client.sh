#!/bin/bash

#### Kerberos client setup

. /tmp/params.sh

yum install -y krb5-pkinit-openssl krb5-server-ldap words krb5-workstation cyrus-sasl-gssapi pam_krb5 

mv /etc/krb5.conf /etc/krb5.conf.`date +"%Y%m%d%H%M%S%N"`

cat <<EOF > /tmp/krb5.conf
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = ${CLUSTER_REALM}
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
  ${CLUSTER_REALM} = {
  kdc = ${KDC_HOST}
  admin_server = ${KDC_HOST}
 }

[domain_realm]
 .${CLUSTER_DOMAIN} = ${CLUSTER_REALM}
 ${CLUSTER_DOMAIN} = ${CLUSTER_REALM}
EOF
mv /tmp/krb5.conf /etc/krb5.conf 



#HADOOP_JAAS_DEBUG=true
#HADOOP_OPTS="-Dsun.security.krb5.debug=true"