#!/bin/bash

#### Kerberos client setup

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

#### Kerberos client setup
echo "==> Installing Kerberos client"

if [[ -z ${REALM_NAME} || -z ${KDC_HOST_NAME} || -z ${DOMAIN_NAME} ]]; then 
	echo ' ${REALM_NAME}, ${KDC_HOST_NAME}, ${DOMAIN_NAME} must be defined'
	exit 1
fi

echo "REALM_NAME: ${REALM_NAME}"
echo "KDC_HOST_NAME: ${KDC_HOST_NAME}"
echo "DOMAIN_NAME: ${DOMAIN_NAME}"


yum install -y krb5-pkinit-openssl krb5-server-ldap words krb5-workstation cyrus-sasl-gssapi pam_krb5 

cat <<EOF > /etc/krb5.conf 
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log


[libdefaults]
 default_realm = ${REALM_NAME}
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 udp_preference_limit = 1

[realms]
  ${REALM_NAME} = {
 kdc = ${KDC_HOST_NAME}
  admin_server = ${KDC_HOST_NAME}
 }

[domain_realm]
.${DOMAIN_NAME} = ${REALM_NAME}
 ${DOMAIN_NAME} = ${REALM_NAME}
EOF


#HADOOP_JAAS_DEBUG=true
#HADOOP_OPTS="-Dsun.security.krb5.debug=true"