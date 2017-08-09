#!/bin/bash

#LDAP SASL kerberos

#To debug things
#/usr/sbin/saslauthd -m /run/saslauthd -a kerberos5 -d

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

#### Kerberos server setup

echo "==> Installing LDAP SASL kerberos"

if [[ -z ${REALM_NAME} || -z ${DEFAULT_PASSWORD} ]]; then 
	echo ' ${REALM_NAME}, ${DEFAULT_PASSWORD} must be defined'
	exit 1
fi
echo "Realm: ${REALM_NAME}"


yum -y install cyrus-sasl

cat <<EOF > /etc/sysconfig/saslauthd
# Directory in which to place saslauthd's listening socket, pid file, and so
# on.  This directory must already exist.
SOCKETDIR=/run/saslauthd

# Mechanism to use when checking passwords.  Run "saslauthd -v" to get a list
# of which mechanism your installation was compiled with the ablity to use.
MECH=kerberos5

# Additional flags to pass to saslauthd on the command line.  See saslauthd(8)
# for the list of accepted flags.
FLAGS=
EOF

cat <<EOF > /etc/sasl2/slapd.conf
pwcheck_method: saslauthd
EOF

host_fqdn=$(hostname -f)
principal_name=host/${host_fqdn}

printf "%b" "add_principal -pw ${DEFAULT_PASSWORD} ${principal_name}" | kadmin.local

printf "%b" "ktadd -k /tmp/${host_fqdn}.keytab ${principal_name}" | kadmin.local
mv -f /tmp/${host_fqdn}.keytab /etc/krb5.keytab

systemctl restart saslauthd.service
systemctl enable saslauthd.service


#testsaslauthd -u admin1@${DOMAIN_NAME} -p not_the_password
#testsaslauthd -u admin1@${DOMAIN_NAME} -p ${DEFAULT_PASSWORD}

