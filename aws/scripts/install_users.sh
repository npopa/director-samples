#!/bin/bash

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -z ${LDAP_SUFFIX} || -z ${REALM_NAME} ]]; then 
	echo ' ${LDAP_SUFFIX}, ${REALM_NAME} must be defined'
	exit 1
fi

if [[ -z ${DEFAULT_PASSWORD} ]]; then 
	echo ' ${DEFAULT_PASSWORD} must be defined'
	exit 1
fi

#Parse "id(user)" into two variables using below
#GROUP_NAME=$(echo $LINUX_USER_GROUP|cut -f2 -d"("|tr -d ")")
#GROUP_GID=$(echo $LINUX_USER_GROUP|cut -f1 -d"(")

#Clean up if required
#ldapsearch -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -b "${LDAP_SUFFIX}" "(objectclass=account)"|grep dn:|awk '{print $2}'|ldapdelete -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}"
#ldapsearch -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -b "${LDAP_SUFFIX}" "(objectclass=groupOfNames)"|grep dn:|awk '{print $2}'|ldapdelete -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}"

#Tests
#ldapsearch -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -b "${LDAP_SUFFIX}" "(objectclass=*)"
#getent group lxusers
#id u573801


#Remove comments and blank lines
#grep -vE '^(\s*$|#)' /tmp/users.txt #this works but leaves the inline comments
#sed -e 's/#.*$//' -e '/^\s*$/d' /tmp/users.txt

rm -rf /tmp/ldap_user_entries.ldif
rm -rf /tmp/ldap_group_entries.ldif
rm -rf /tmp/ldap_group_members.ldif

sed -e 's/#.*$//' -e '/^\s*$/d' /tmp/users.txt|\
while read line; do
	#echo "Input line:" $line
	USER_PART=$(echo $line|cut -d' ' -f1|cut -d'=' -f2)
	GID_PART=$(echo $line|cut -d' ' -f2|cut -d'=' -f2)
	GROUP_PART=$(echo $line|cut -d' ' -f3|cut -d'=' -f2)

	USER_UID=$(echo $USER_PART|cut -f1 -d"(")
	USER_NAME=$(echo $USER_PART|cut -f2 -d"("|tr -d ")")

	PRIMARY_GID=$(echo $GID_PART|cut -f1 -d"(")
	PRIMARY_GROUP=$(echo $GID_PART|cut -f2 -d"("|tr -d ")")

	SECONDARY_GROUPS=$GROUP_PART

	#echo "Parse line:" $USER_UID, $USER_NAME, $PRIMARY_GID, $PRIMARY_GROUP, $SECONDARY_GROUPS

	cat<<EOF >>/tmp/ldap_user_entries.ldif
dn: cn=$USER_NAME,ou=People,${LDAP_SUFFIX}
objectClass: shadowAccount
objectClass: top
objectClass: posixAccount
objectClass: account
cn: ${USER_NAME}
gidNumber: ${PRIMARY_GID}
homeDirectory: /home/${USER_NAME}
uid: ${USER_NAME}
uidNumber: ${USER_UID}
loginShell: /bin/bash
shadowLastChange: 0
shadowMax: 99999
shadowWarning: 0
userPassword: {SASL}${USER_NAME}@${REALM_NAME}

dn: cn=${PRIMARY_GROUP},ou=Group,${LDAP_SUFFIX}
objectClass: top
objectClass: groupOfNames
objectClass: posixGroup
cn: ${PRIMARY_GROUP}
gidNumber: ${PRIMARY_GID}
memberUid: ${USER_NAME}
member: cn=${USER_NAME},ou=People,${LDAP_SUFFIX}

EOF



	IFS=',' read -a groups_arr <<< $SECONDARY_GROUPS
	for SECONDARY_GROUP in "${groups_arr[@]}"
	do
		#echo "Group: $SECONDARY_GROUP"
		SECONDARY_GID=$(echo $SECONDARY_GROUP|cut -f1 -d"(")
		SECONDARY_GROUP_NAME=$(echo $SECONDARY_GROUP|cut -f2 -d"("|tr -d ")")
		#search the group in LDAP. If LDAP is empty then it would not be required.
		LDAP_EXISTS_GROUP=$(ldapsearch -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -b "${LDAP_SUFFIX}" "(&(objectclass=groupOfNames)(gidNumber=${SECONDARY_GID}))" gidNumber|grep "gidNumber"|grep -v "#")
		#If the group was already added as part of the current run
		if [[ -f /tmp/ldap_group_entries.ldif ]]; then
			EXISTS_GROUP=$(grep ${SECONDARY_GID} /tmp/ldap_group_entries.ldif|grep "gidNumber")
		else
			EXISTS_GROUP=""
		fi

		if [[ -z $LDAP_EXISTS_GROUP && -z $EXISTS_GROUP ]]; then #if the group does not exist create group entry
			#echo "Creating group ${SECONDARY_GROUP_NAME}, ${SECONDARY_GID}"
			cat<<EOF >>/tmp/ldap_group_entries.ldif
dn: cn=${SECONDARY_GROUP_NAME},ou=Group,${LDAP_SUFFIX}
objectClass: top
objectClass: groupOfNames
objectClass: posixGroup
cn: ${SECONDARY_GROUP_NAME}
gidNumber: ${SECONDARY_GID}
memberUid: ${USER_NAME}
member: cn=${USER_NAME},ou=People,${LDAP_SUFFIX}

EOF

		else
		cat<<EOF >>/tmp/ldap_group_members.ldif
dn: cn=${SECONDARY_GROUP_NAME},ou=Group,${LDAP_SUFFIX}
changetype: modify
add: memberUid
memberUid: ${USER_NAME}

dn: cn=${SECONDARY_GROUP_NAME},ou=Group,${LDAP_SUFFIX}
changetype: modify
add: member
member: cn=${USER_NAME},ou=People,${LDAP_SUFFIX}

EOF
		fi
	done
	#add user to KDC and set a password
	printf "%b" "add_principal -pw ${DEFAULT_PASSWORD} ${USER_NAME}" | kadmin.local

done

ldapadd -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -f /tmp/ldap_user_entries.ldif
ldapadd -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -f /tmp/ldap_group_entries.ldif
ldapmodify -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -f /tmp/ldap_group_members.ldif

