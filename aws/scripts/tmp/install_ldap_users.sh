#!/bin/bash

#Generate users/groups

. /tmp/params.sh

echo>/tmp/ldap_entries.ldif
export UID_NUMBER=5000
export MY_USERS="admin1 admin2 user1 user2 user3 user4 user5"
for u in $MY_USERS; do
    echo ${u}, ${UID_NUMBER}
    let GID_NUMBER=${UID_NUMBER}+10000
    cat<<EOF >>/tmp/ldap_entries.ldif
dn: cn=${u},ou=People,${LDAP_SUFFIX}
objectClass: shadowAccount
objectClass: top
objectClass: posixAccount
objectClass: account
cn: ${u}
gidNumber: ${GID_NUMBER}
homeDirectory: /home/${u}
uid: ${u}
uidNumber: ${UID_NUMBER}
loginShell: /bin/bash
shadowLastChange: 0
shadowMax: 99999
shadowWarning: 0
userPassword: {SASL}${u}@${CLUSTER_REALM}

dn: cn=${u},ou=Group,${LDAP_SUFFIX}
objectClass: top
objectClass: groupOfNames
objectClass: posixGroup
cn: ${u}
gidNumber: ${GID_NUMBER}
memberUid: ${u}
member: cn=${u},ou=People,${LDAP_SUFFIX}

EOF

    let UID_NUMBER=${UID_NUMBER}+1
done

ldapadd -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -f /tmp/ldap_entries.ldif

#generate six char string
#head -c 128 /dev/random | LC_CTYPE=C tr -dc "[:lower:]"|head -c 6