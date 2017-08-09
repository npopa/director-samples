#!/bin/bash

### Install ldap server

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -z ${DEFAULT_PASSWORD} || -z ${LDAP_SUFFIX} || -z ${LDAP_DC} ]]; then 
	echo ' ${DEFAULT_PASSWORD}, ${LDAP_SUFFIX}, ${LDAP_DC} must be defined'
	exit 1
fi
##### LDAP
#to enable logging 
#sudo vi /etc/rsyslog.conf
#add --->  local4.*    /var/log/slapd.log;slapdtmpl
#service rsyslog restart

export LDAP_SETUP=/tmp

yum install -y openldap-clients  openldap-devel openldap-servers pam_krb5 cyrus-sasl-gssapi krb5-workstation 
yum install -y  openldap compat-openldap openldap-clients openldap-servers openldap-servers-sql openldap-devel

systemctl start slapd.service
systemctl enable slapd.service

LDAP_ADMIN_PASS=$(slappasswd -s ${DEFAULT_PASSWORD})

cat > ${LDAP_SETUP}/db.ldif <<EOT
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: ${LDAP_SUFFIX}

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,${LDAP_SUFFIX}

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: ${LDAP_ADMIN_PASS}
EOT

ldapmodify -Y EXTERNAL  -H ldapi:/// -f ${LDAP_SETUP}/db.ldif

cat > ${LDAP_SETUP}/monitor.ldif <<EOT
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth" read by dn.base="cn=ldapadm,${LDAP_SUFFIX}" read by * none
EOT
ldapmodify -Y EXTERNAL  -H ldapi:/// -f ${LDAP_SETUP}/monitor.ldif

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap:ldap /var/lib/ldap/*
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif

cat > /etc/openldap/schema/rfc2307bis.ldif <<EOT
# AUTO-GENERATED FILE - DO NOT EDIT!! Use ldapmodify.
# CRC32 bc7a6935
dn: cn=rfc2307bis,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: rfc2307bis
olcAttributeTypes: {0}( 1.3.6.1.1.1.1.2 NAME 'gecos' DESC 'The GECOS field; th
 e common name' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNT
 AX 1.3.6.1.4.1.1466.115.121.1.15 SINGLE-VALUE )
olcAttributeTypes: {1}( 1.3.6.1.1.1.1.3 NAME 'homeDirectory' DESC 'The absolut
 e path to the home directory' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1
 466.115.121.1.26 SINGLE-VALUE )
olcAttributeTypes: {2}( 1.3.6.1.1.1.1.4 NAME 'loginShell' DESC 'The path to th
 e login shell' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.2
 6 SINGLE-VALUE )
olcAttributeTypes: {3}( 1.3.6.1.1.1.1.5 NAME 'shadowLastChange' EQUALITY integ
 erMatch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SI
 NGLE-VALUE )
olcAttributeTypes: {4}( 1.3.6.1.1.1.1.6 NAME 'shadowMin' EQUALITY integerMatch
  ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VA
 LUE )
olcAttributeTypes: {5}( 1.3.6.1.1.1.1.7 NAME 'shadowMax' EQUALITY integerMatch
  ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-VA
 LUE )
olcAttributeTypes: {6}( 1.3.6.1.1.1.1.8 NAME 'shadowWarning' EQUALITY integerM
 atch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGL
 E-VALUE )
olcAttributeTypes: {7}( 1.3.6.1.1.1.1.9 NAME 'shadowInactive' EQUALITY integer
 Match ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SING
 LE-VALUE )
olcAttributeTypes: {8}( 1.3.6.1.1.1.1.10 NAME 'shadowExpire' EQUALITY integerM
 atch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGL
 E-VALUE )
olcAttributeTypes: {9}( 1.3.6.1.1.1.1.11 NAME 'shadowFlag' EQUALITY integerMat
 ch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 SINGLE-
 VALUE )
olcAttributeTypes: {10}( 1.3.6.1.1.1.1.12 NAME 'memberUid' EQUALITY caseExactM
 atch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: {11}( 1.3.6.1.1.1.1.13 NAME 'memberNisNetgroup' EQUALITY ca
 seExactMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: {12}( 1.3.6.1.1.1.1.14 NAME 'nisNetgroupTriple' DESC 'Netgr
 oup triple' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 
 1.3.6.1.4.1.1466.115.121.1.15 )
olcAttributeTypes: {13}( 1.3.6.1.1.1.1.15 NAME 'ipServicePort' DESC 'Service p
 ort number' EQUALITY integerMatch ORDERING integerOrderingMatch SYNTAX 1.3.6.
 1.4.1.1466.115.121.1.27 SINGLE-VALUE )
olcAttributeTypes: {14}( 1.3.6.1.1.1.1.16 NAME 'ipServiceProtocol' DESC 'Servi
 ce protocol name' EQUALITY caseIgnoreMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.
 15 )
olcAttributeTypes: {15}( 1.3.6.1.1.1.1.17 NAME 'ipProtocolNumber' DESC 'IP pro
 tocol number' EQUALITY integerMatch ORDERING integerOrderingMatch SYNTAX 1.3.
 6.1.4.1.1466.115.121.1.27 SINGLE-VALUE )
olcAttributeTypes: {16}( 1.3.6.1.1.1.1.18 NAME 'oncRpcNumber' DESC 'ONC RPC nu
 mber' EQUALITY integerMatch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.
 1466.115.121.1.27 SINGLE-VALUE )
olcAttributeTypes: {17}( 1.3.6.1.1.1.1.19 NAME 'ipHostNumber' DESC 'IPv4 addre
 sses as a dotted decimal omitting leading               zeros or IPv6 address
 es as defined in RFC2373' EQUALITY caseIgnoreIA5Match SYNTAX 1.3.6.1.4.1.1466
 .115.121.1.26 )
olcAttributeTypes: {18}( 1.3.6.1.1.1.1.20 NAME 'ipNetworkNumber' DESC 'IP netw
 ork omitting leading zeros, eg. 192.168' EQUALITY caseIgnoreIA5Match SYNTAX 1
 .3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )
olcAttributeTypes: {19}( 1.3.6.1.1.1.1.21 NAME 'ipNetmaskNumber' DESC 'IP netm
 ask omitting leading zeros, eg. 255.255.255.0' EQUALITY caseIgnoreIA5Match SY
 NTAX 1.3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )
olcAttributeTypes: {20}( 1.3.6.1.1.1.1.22 NAME 'macAddress' DESC 'MAC address 
 in maximal, colon separated hex               notation, eg. 00:00:92:90:ee:e2
 ' EQUALITY caseIgnoreIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: {21}( 1.3.6.1.1.1.1.23 NAME 'bootParameter' DESC 'rpc.bootp
 aramd parameter' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1
 .26 )
olcAttributeTypes: {22}( 1.3.6.1.1.1.1.24 NAME 'bootFile' DESC 'Boot image nam
 e' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: {23}( 1.3.6.1.1.1.1.26 NAME 'nisMapName' DESC 'Name of a ge
 neric NIS map' EQUALITY caseIgnoreMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{
 64} )
olcAttributeTypes: {24}( 1.3.6.1.1.1.1.27 NAME 'nisMapEntry' DESC 'A generic N
 IS entry' EQUALITY caseExactMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{1024} 
 SINGLE-VALUE )
olcAttributeTypes: {25}( 1.3.6.1.1.1.1.28 NAME 'nisPublicKey' DESC 'NIS public
  key' EQUALITY octetStringMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 SINGLE-V
 ALUE )
olcAttributeTypes: {26}( 1.3.6.1.1.1.1.29 NAME 'nisSecretKey' DESC 'NIS secret
  key' EQUALITY octetStringMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 SINGLE-V
 ALUE )
olcAttributeTypes: {27}( 1.3.6.1.1.1.1.30 NAME 'nisDomain' DESC 'NIS domain' E
 QUALITY caseIgnoreIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26{256} )
olcAttributeTypes: {28}( 1.3.6.1.1.1.1.31 NAME 'automountMapName' DESC 'automo
 unt Map Name' EQUALITY caseExactMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 SI
 NGLE-VALUE )
olcAttributeTypes: {29}( 1.3.6.1.1.1.1.32 NAME 'automountKey' DESC 'Automount 
 Key value' EQUALITY caseExactMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 SINGL
 E-VALUE )
olcAttributeTypes: {30}( 1.3.6.1.1.1.1.33 NAME 'automountInformation' DESC 'Au
 tomount information' EQUALITY caseExactMatch SYNTAX 1.3.6.1.4.1.1466.115.121.
 1.15 SINGLE-VALUE )
olcObjectClasses: {0}( 1.3.6.1.1.1.2.0 NAME 'posixAccount' DESC 'Abstraction o
 f an account with POSIX attributes' SUP top AUXILIARY MUST ( cn $ uid $ uidNu
 mber $ gidNumber $ homeDirectory ) MAY ( userPassword $ loginShell $ gecos $ 
 description ) )
olcObjectClasses: {1}( 1.3.6.1.1.1.2.1 NAME 'shadowAccount' DESC 'Additional a
 ttributes for shadow passwords' SUP top AUXILIARY MUST uid MAY ( userPassword
  $ description $ shadowLastChange $ shadowMin $ shadowMax $ shadowWarning $ s
 hadowInactive $ shadowExpire $ shadowFlag ) )
olcObjectClasses: {2}( 1.3.6.1.1.1.2.2 NAME 'posixGroup' DESC 'Abstraction of 
 a group of accounts' SUP top AUXILIARY MUST gidNumber MAY ( userPassword $ me
 mberUid $ description ) )
olcObjectClasses: {3}( 1.3.6.1.1.1.2.3 NAME 'ipService' DESC 'Abstraction an I
 nternet Protocol service.               Maps an IP port and protocol (such as
  tcp or udp)               to one or more names; the distinguished value of  
              the cn attribute denotes the services canonical               na
 me' SUP top STRUCTURAL MUST ( cn $ ipServicePort $ ipServiceProtocol ) MAY de
 scription )
olcObjectClasses: {4}( 1.3.6.1.1.1.2.4 NAME 'ipProtocol' DESC 'Abstraction of 
 an IP protocol. Maps a protocol number               to one or more names. Th
 e distinguished value of the cn               attribute denotes the protocol 
 canonical name' SUP top STRUCTURAL MUST ( cn $ ipProtocolNumber ) MAY descrip
 tion )
olcObjectClasses: {5}( 1.3.6.1.1.1.2.5 NAME 'oncRpc' DESC 'Abstraction of an O
 pen Network Computing (ONC)              [RFC1057] Remote Procedure Call (RPC
 ) binding.              This class maps an ONC RPC number to a name.         
      The distinguished value of the cn attribute denotes              the RPC
  service canonical name' SUP top STRUCTURAL MUST ( cn $ oncRpcNumber ) MAY de
 scription )
olcObjectClasses: {6}( 1.3.6.1.1.1.2.6 NAME 'ipHost' DESC 'Abstraction of a ho
 st, an IP device. The distinguished               value of the cn attribute d
 enotes the hosts canonical            name. Device SHOULD be used as a struct
 ural class' SUP top AUXILIARY MUST ( cn $ ipHostNumber ) MAY ( userPassword $
  l $ description $ manager ) )
olcObjectClasses: {7}( 1.3.6.1.1.1.2.7 NAME 'ipNetwork' DESC 'Abstraction of a
  network. The distinguished value of               the cn attribute denotes t
 he network canonical name' SUP top STRUCTURAL MUST ipNetworkNumber MAY ( cn $
  ipNetmaskNumber $ l $ description $ manager ) )
olcObjectClasses: {8}( 1.3.6.1.1.1.2.8 NAME 'nisNetgroup' DESC 'Abstraction of
  a netgroup. May refer to other               netgroups' SUP top STRUCTURAL M
 UST cn MAY ( nisNetgroupTriple $ memberNisNetgroup $ description ) )
olcObjectClasses: {9}( 1.3.6.1.1.1.2.9 NAME 'nisMap' DESC 'A generic abstracti
 on of a NIS map' SUP top STRUCTURAL MUST nisMapName MAY description )
olcObjectClasses: {10}( 1.3.6.1.1.1.2.10 NAME 'nisObject' DESC 'An entry in a 
 NIS map' SUP top STRUCTURAL MUST ( cn $ nisMapEntry $ nisMapName ) )
olcObjectClasses: {11}( 1.3.6.1.1.1.2.11 NAME 'ieee802Device' DESC 'A device w
 ith a MAC address; device SHOULD be               used as a structural class'
  SUP top AUXILIARY MAY macAddress )
olcObjectClasses: {12}( 1.3.6.1.1.1.2.12 NAME 'bootableDevice' DESC 'A device 
 with boot parameters; device SHOULD be               used as a structural cla
 ss' SUP top AUXILIARY MAY ( bootFile $ bootParameter ) )
olcObjectClasses: {13}( 1.3.6.1.1.1.2.14 NAME 'nisKeyObject' DESC 'An object w
 ith a public and secret key' SUP top AUXILIARY MUST ( cn $ nisPublicKey $ nis
 SecretKey ) MAY ( uidNumber $ description ) )
olcObjectClasses: {14}( 1.3.6.1.1.1.2.15 NAME 'nisDomainObject' DESC 'Associat
 es a NIS domain with a naming context' SUP top AUXILIARY MUST nisDomain )
olcObjectClasses: {15}( 1.3.6.1.1.1.2.16 NAME 'automountMap' SUP top STRUCTURA
 L MUST automountMapName MAY description )
olcObjectClasses: {16}( 1.3.6.1.1.1.2.17 NAME 'automount' DESC 'Automount info
 rmation' SUP top STRUCTURAL MUST ( automountKey $ automountInformation ) MAY 
 description )
olcObjectClasses: {17}( 1.3.6.1.1.1.2.18 NAME 'groupOfMembers' DESC 'A group w
 ith members (DNs)' SUP top STRUCTURAL MUST cn MAY ( businessCategory $ seeAls
 o $ owner $ ou $ o $ description $ member ) )
EOT

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/rfc2307bis.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

cat > ${LDAP_SETUP}/base.ldif <<EOT
dn: ${LDAP_SUFFIX}
dc: ${LDAP_DC}
objectClass: top
objectClass: domain

dn: cn=ldapadm ,${LDAP_SUFFIX}
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager

dn: ou=People,${LDAP_SUFFIX}
objectClass: organizationalUnit
ou: People

dn: ou=Group,${LDAP_SUFFIX}
objectClass: organizationalUnit
ou: Group
EOT
ldapadd -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -f ${LDAP_SETUP}/base.ldif



#Add memberOf
cat > ${LDAP_SETUP}/backend.memberof.ldif <<EOT
dn: cn=module,cn=config
cn: module
objectClass: olcModuleList
olcModuleLoad: memberof.la
olcModulePath: /usr/lib64/openldap

dn: olcOverlay={0}memberof,olcDatabase={2}hdb,cn=config
objectClass: olcConfig
objectClass: olcMemberOf
objectClass: olcOverlayConfig
objectClass: top
olcOverlay: memberof
olcMemberOfDangling: ignore
olcMemberOfRefInt: TRUE
olcMemberOfGroupOC: groupOfNames
olcMemberOfMemberAD: member
olcMemberOfMemberOfAD: memberOf
EOT
ldapadd -Y EXTERNAL -H ldapi:/// -f ${LDAP_SETUP}/backend.memberof.ldif

cat > ${LDAP_SETUP}/backend.refint.ldif <<EOT
dn: cn=module,cn=config
cn: module
objectclass: olcModuleList
objectclass: top
olcmoduleload: refint.la
olcmodulepath: /usr/lib64/openldap

dn: olcOverlay={1}refint,olcDatabase={2}hdb,cn=config
objectClass: olcConfig
objectClass: olcOverlayConfig
objectClass: olcRefintConfig
objectClass: top
olcOverlay: {1}refint
olcRefintAttribute: memberof member manager owner
EOT
ldapadd -Y EXTERNAL -H ldapi:/// -f ${LDAP_SETUP}/backend.refint.ldif

ldapsearch -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -b "${LDAP_SUFFIX}" "(objectclass=*)"


#ldapadd -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -f ldap_users.ldif
#ldapadd -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -f ldap_groups.ldif
#ldapsearch -x -w ${DEFAULT_PASSWORD} -D "cn=ldapadm,${LDAP_SUFFIX}" -b cn=admin1,ou=People,${LDAP_SUFFIX} dn memberof
#ldapsearch -x -W -D "cn=sysadmin,ou=People,${LDAP_SUFFIX}" -b cn=npopa,ou=People,${LDAP_SUFFIX} dn memberof
