#!/bin/bash

### Agents SSL

. /tmp/params.sh

export PEM_KEY="/opt/cloudera/security/x509/key.pem"
export PEM_KEY_PASSWORD="cloudera"
export PEM_KEY_NOPASSWORD="/opt/cloudera/security/x509/keynopw.pem"
export PEM_CERT="/opt/cloudera/security/x509/cert.pem"
export PEM_CACERT="/opt/cloudera/security/truststore/ca-truststore.pem"

#Make a backup but don't overwrite
cp -n /etc/cloudera-scm-agent/config.ini /etc/cloudera-scm-agent/config.ini.orig
cat /etc/cloudera-scm-agent/config.ini.orig | sed "s/use_tls=0/use_tls=1/" > /etc/cloudera-scm-agent/config.ini.level-1
cat /etc/cloudera-scm-agent/config.ini.level-1 | sed "s|# verify_cert_file=|verify_cert_dir=${PEM_CACERT}|" > /etc/cloudera-scm-agent/config.ini.level-2
echo ${PEM_KEY_PASSWORD}>/etc/cloudera-scm-agent/agentkey.pw
cat /etc/cloudera-scm-agent/config.ini.level-2 | sed -e "s|# client_key_file=|client_key_file=${PEM_KEY}|" \
                                            -e "s|# client_cert_file=|client_cert_file=${PEM_CERT}|" \
                                            -e "s|# client_keypw_file=|client_keypw_file=/etc/cloudera-scm-agent/agentkey.pw|" > /etc/cloudera-scm-agent/config.ini.level-3

ls -s /etc/cloudera-scm-agent/config.ini.level-3 /etc/cloudera-scm-agent/config.ini



