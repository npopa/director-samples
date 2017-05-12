#!/bin/bash 

##Build director node

sed -i "s/DIRECTOR_HOST=.*/DIRECTOR_HOST=$(hostname -f)/g" ./params.sh

sudo ./secrets.sh
sudo ./params.sh
sudo ./normalize_el7.sh
sudo ./install_proxy_server.sh
sudo ./install_java8.sh
sudo ./install_puppet_server.sh
sudo ./install_mysql_server.sh
sudo ./install_mysql_dbs.sh
sudo ./install_mysql_connector.sh
sudo ./install_kerberos_client.sh
sudo ./install_kerberos_server.sh
sudo ./install_ldap_server.sh
sudo ./install_ldap_users.sh
sudo ./install_user_principals.sh
sudo ./install_saslauthd.sh
sudo ./install_sssd.sh

sudo ./install_director.sh



