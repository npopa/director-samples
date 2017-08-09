#!/bin/bash

### Add kerberos principals for some users

. /tmp/params.sh

export ADDPRINC_SH=/tmp/addprinc
export EXPORTKEYTAB_SH=/tmp/exportkeytab

yum install -y expect


cat <<END > ${ADDPRINC_SH}
#!/usr/bin/expect -f
set timeout 5000
set principal_instance [lindex \$argv 0]
set realm [lindex \$argv 1]
set password [lindex \$argv 2]
spawn sudo kadmin.local -q "addprinc \$principal_instance@\$realm"
expect -re {Enter password for principal .*} { send "\$password\r" }
expect -re {Re-enter password for principal .* } { send "\$password\r" }
expect EOF
END
chmod +x ${ADDPRINC_SH}

#This seems cleaner:
#printf "%b" "add_principal -randkey ${principal_name}" | kadmin.local


#### Add few principals 
export MY_USERS="scm/admin admin1 admin2 user1 user2 user3 user4 user5"

for u in ${MY_USERS}; do
    ${ADDPRINC_SH} ${u} ${CLUSTER_REALM} ${DEFAULT_PASSWORD}
done