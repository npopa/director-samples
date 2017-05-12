#!/bin/bash

#### Kerberos server setup

. /tmp/params.sh


yum install -y krb5-server krb5-pkinit-openssl krb5-server-ldap words krb5-workstation cyrus-sasl-gssapi pam_krb5 

mv /var/kerberos/krb5kdc/kdc.conf /var/kerberos/krb5kdc/kdc.conf.`date +"%Y%m%d%H%M%S%N"`
cat <<EOF > /tmp/kdc.conf
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 ${CLUSTER_REALM} = {
  max_renewable_life = 7d 0h 0m 0s
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal arcfour-hmac:normal
  default_principal_flags = +renewable
 }
EOF
sudo mv /tmp/kdc.conf /var/kerberos/krb5kdc/kdc.conf

sudo mv /var/kerberos/krb5kdc/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl.`date +"%Y%m%d%H%M%S%N"`
sudo cat <<EOF > /tmp/kadm5.acl
*/admin@${CLUSTER_REALM}   *
EOF
sudo mv /tmp/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl

sudo kdb5_util create -s -P ${KDC_ADMIN_PASSWORD}

sudo service krb5kdc restart 
sudo service kadmin restart 
sudo chkconfig kadmin on
sudo chkconfig krb5kdc on
