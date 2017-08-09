#!/bin/bash

##### Various parameters 

rm -rf /tmp/secrets.sh
touch /tmp/secrets.sh
chmod 755 /tmp/secrets.sh
chown root:root /tmp/secrets.sh

cat <<-\EOF >/tmp/secrets.sh
#This file contains all the sensitive information (keys, passwords etc.)

#TODO - This file should be removed at the end of the install automatically
export DEFAULT_PASSWORD="cloudera"

EOF


