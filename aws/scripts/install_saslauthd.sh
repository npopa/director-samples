#!/bin/bash

#LDAP SASL kerberos

#To debug things
#/usr/sbin/saslauthd -m /run/saslauthd -a kerberos5 -d


. /tmp/params.sh

yum -y install cyrus-sasl

cat <<EOF > /tmp/saslauthd 
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
mv /tmp/saslauthd  /etc/sysconfig/saslauthd


cat <<EOF > /tmp/slapd.conf
pwcheck_method: saslauthd
EOF
mv /tmp/slapd.conf /etc/sasl2/slapd.conf

host_fqdn=$(hostname -f)
principal_name=host/${host_fqdn}

printf "%b" "add_principal -pw ${DEFAULT_PASSWORD} ${principal_name}" | kadmin.local

#printf "%b" "addent -password -p ${principal_name} -k 1 -e aes256-cts-hmac-sha1-96\n${DEFAULT_PASSWORD}\n\
#             addent -password -p ${principal_name} -k 1 -e arcfour-hmac\n${DEFAULT_PASSWORD}\n\
#             write_kt ${host_fqdn}.keytab" | ktutil

printf "%b" "ktadd -k /tmp/${host_fqdn}.keytab ${principal_name}" | kadmin.local
mv -f /tmp/${host_fqdn}.keytab /etc/krb5.keytab

systemctl restart saslauthd.service
systemctl enable saslauthd.service

#need to have a krb5.keytab for the host.
#[root@ip-10-10-10-91 ~]# klist -kt /etc/krb5.keytab -e
#Keytab name: FILE:/etc/krb5.keytab
#KVNO Timestamp           Principal
#---- ------------------- ------------------------------------------------------
#   2 04/05/2017 02:18:19 host/ip-10-10-10-91.us-west-2.compute.internal@CLOUDERA.LAN (aes256-cts-hmac-sha1-96)
#   2 04/05/2017 02:18:19 host/ip-10-10-10-91.us-west-2.compute.internal@CLOUDERA.LAN (arcfour-hmac)


testsaslauthd -u admin1@${CLUSTER_DOMAIN} -p not_the_password
testsaslauthd -u admin1@${CLUSTER_DOMAIN} -p ${DEFAULT_PASSWORD}

#ldapsearch -x -W -D "cn=admin1,ou=People,dc=threeosix,dc=lan" -b cn=admin1,ou=People,dc=threeosix,dc=lan dn memberof

#Nice way to get a keytab
#[npopa@npopa-director tmp]$ printf "%b" "addent -password -p host/npopa-director.threeosix.lan@THREEOSIX.LAN -k 1 -e aes256-cts-hmac-sha1-96\ncloudera\naddent -password -p host/npopa-director.threeosix.lan@THREEOSIX.LAN -k 1 -e arcfour-hmac\ncloudera\nwrite_kt npopa-director.threeosix.lan.keytab" | ktutil
#ktutil:  addent -password -p host/npopa-director.threeosix.lan@THREEOSIX.LAN -k 1 -e aes256-cts-hmac-sha1-96
#Password for host/npopa-director.threeosix.lan@THREEOSIX.LAN:
#ktutil:  write_kt npopa-director.threeosix.lan.keytab
#ktutil:  [npopa@npopa-director tmp]$ ls -tlr npopa-director.threeosix.lan.keytab
#-rw-------. 1 npopa npopa 108 Apr 15 19:59 npopa-director.threeosix.lan.keytab
#[npopa@npopa-director tmp]$ klist -kt npopa-director.threeosix.lan.keytab -e
#Keytab name: FILE:npopa-director.threeosix.lan.keytab
#KVNO Timestamp           Principal
#---- ------------------- ------------------------------------------------------
#   1 04/15/2017 19:59:58 host/npopa-director.threeosix.lan@THREEOSIX.LAN (aes256-cts-hmac-sha1-96)

#addprinc host/ip-10-14-0-4.threeosix.lan THREEOSIX.LAN cloudera
#printf "%b" "addent -password -p host/ip-10-14-0-4.threeosix.lan@THREEOSIX.LAN -k 1 -e aes256-cts-hmac-sha1-96\ncloudera\n\
#             addent -password -p host/ip-10-14-0-4.threeosix.lan@THREEOSIX.LAN -k 1 -e arcfour-hmac\ncloudera\n\
#             write_kt ip-10-14-0-4.threeosix.lan.keytab" | ktutil

#new_hostname=ip-$(hostname -i |tr '.' '-')


