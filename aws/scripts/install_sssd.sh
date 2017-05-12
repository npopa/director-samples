#!/bin/bash

. /tmp/params.sh

##### SSSD

yum install -y sssd oddjob oddjob-mkhomedir openldap-devel pam_krb5 cyrus-sasl-gssapi authconfig

authconfig \
--enablesssd \
--enablesssdauth \
--enablelocauthorize \
--enablemkhomedir \
--enablecachecreds \
--update

cat > /tmp/sssd.conf <<EOT
[sssd]
config_file_version = 2
reconnection_retries = 3
sbus_timeout = 30
services = nss, pam
domains = LOCAL,default

[nss]
filter_groups = root
filter_users = root
reconnection_retries = 3
#entry_cache_timeout = 300
entry_cache_nowait_percentage = 75

[pam]
reconnection_retries = 3
offline_credentials_expiration = 0
offline_failed_login_attempts = 0
offline_failed_login_delay = 5

[domain/LOCAL]
id_provider = local
min_id = 1
max_id = 499
enumerate = False

[domain/default]
description = Kerberos MIT domain
id_provider = ldap
#ldap_access_filter = (memberOf=cn=hadoop_admin,ou=Groups,dc=commit,dc=lan)
min_id = 500
enumerate = True
timeout = 10
cache_credentials = True
entry_cache_timeout = 300

# General -----------------------
# LDAP
#debug_level = 9
ldap_purge_cache_timeout = 1
ldap_uri = ldap://${LDAP_HOST}
ldap_search_base = ${LDAP_SUFFIX}
ldap_user_search_base = ${LDAP_SUFFIX}
ldap_group_search_base = ${LDAP_SUFFIX}
ldap_referrals = False
ldap_schema = rfc2307bis
ldap_search_timeout = 5
ldap_network_timeout = 5
#ldap_sasl_mech = GSSAPI
#ldap_sasl_authid = host/<host>@<REALM>
#ldap_sasl_authid = ldap/<host>@<REALM>
#ldap_krb5_keytab = /etc/krb5.keytab
#ldap_krb5_keytab = /etc/ldap.keytab
ldap_krb5_init_creds = true
ldap_krb5_ticket_lifetime = 86400
#ldap_tls_reqcert = never
#ldap_tls_cacert = /etc/openldap/cacerts/CA.crt
#ldap_tls_reqcert = demand

# KRB5
auth_provider = krb5
chpass_provider = krb5
ldap_force_upper_case_realm = True
krb5_server = ${KDC_HOST}:88
krb5_realm = ${CLUSTER_REALM}
krb5_store_password_if_offline = true
krb5_auth_timeout = 15
krb5_kpasswd = ${KDC_HOST}

# Mapping --------------------
ldap_user_uid_number = uidNumber
ldap_user_gid_number = gidNumber
ldap_user_principal = userPrincipalName
ldap_group_gid_number = gidNumber
ldap_user_gecos = cn
ldap_user_home_directory = homeDirectory
#ldap_id_use_start_tls = True
ldap_user_object_class = posixAccount
ldap_group_object_class = posixGroup
#ldap_group_member = member
ldap_group_name = cn
ldap_user_name = uid
ldap_user_shell = loginShell
EOT
mv /tmp/sssd.conf /etc/sssd
chmod 600 /etc/sssd/sssd.conf

systemctl restart sssd

SSHD_CONF=$(mktemp -t sssd_conf.XXXXXXXXXX)
sed -e 's/PasswordAuthentication no/PasswordAuthentication yes/' \
     -e 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' \
     /etc/ssh/sshd_config > ${SSHD_CONF}

mv ${SSHD_CONF} /etc/ssh/sshd_config
systemctl restart sshd

