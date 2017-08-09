#!/bin/bash

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

#### Kerberos server setup

echo "==> Installing Kerberos MIT server"

if [[ -z ${REALM_NAME} || -z ${DEFAULT_PASSWORD} ]]; then 
	echo ' ${REALM_NAME}, ${DEFAULT_PASSWORD} must be defined'
	exit 1
fi
echo "Realm: ${REALM_NAME}"

yum install -y krb5-server krb5-pkinit-openssl krb5-server-ldap words krb5-workstation cyrus-sasl-gssapi pam_krb5 

cat <<EOF > /var/kerberos/krb5kdc/kdc.conf
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
${REALM_NAME} = {
  max_renewable_life = 7d 0h 0m 0s
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal arcfour-hmac:normal
  default_principal_flags = +renewable
  max_renewable_life = 30d
 }
EOF

cat <<EOF > /var/kerberos/krb5kdc/kadm5.acl
*/admin@${REALM_NAME}   *
EOF

kdb5_util create -s -P ${DEFAULT_PASSWORD}

systemctl start krb5kdc.service
systemctl enable krb5kdc.service
systemctl start kadmin.service
systemctl enable kadmin.service

#TODO - add a default admin principal
#printf "%b" "add_principal -pw ${DEFAULT_PASSWORD} cloudera/admin" | kadmin.local
printf "%b" "add_principal -pw ${DEFAULT_PASSWORD} ${KERBEROS_ADMIN_USER}" | kadmin.local

