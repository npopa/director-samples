#!/bin/bash

### This is a command to generate a key pair for ssh
#ssh-keygen  -b 4096 -t rsa -f ~/.ssh/azure.pem -q -N "" -C "$USER@`hostname -f`"


export DIRECTOR_IP="10.14.0.5"
export SSH_USERNAME='cloudera'
export SSH_PEM_PATH='/home/cloudera/azure.pem'
export CLOUDERA_LICENSE_PATH="/home/cloudera/cdh_license.txt"

export TAGS_OWNER="owner"
export TAGS_PROJECT="Test Cluster"

export AZURE_REGION='eastus'
export AZURE MGMT_URL='https://management.core.windows.net/'
export AZURE_AD_URL='https://login.windows.net/'
export AZURE_SUBSCRIPTION_ID='REPLACE-ME'
export AZURE_TENANT_ID='REPLACE-ME'
export AZURE_CLIENT_ID='REPLACE-ME'
export AZURE_CLIENT_SECRET='REPLACE-ME'

export AZURE_BASE_NODE_SIZE='STANDARD_DS13'







export AZURE_OS='redhat-rhel-72-latest'
export AZURE_NETWORK_SG_RG='user-rg'
export AZURE_NETWORK_SG='user-nsg'
export AZURE_VNET_RG='user-rg'
export AZURE_VNET='user-vnet'
export AZURE_SUBNET='user-subnet'

export AZURE_COMPUTE_RG='user-rg'
export AZURE_AVAILABILITY_SET='user-hadoop'
export AZURE_PUBLIC_IP='No'

export AZURE_MGMT_NODE_SIZE='STANDARD_DS13' 
export AZURE_MGMT_NAME_PREFIX='mgmt'
export AZURE_MGMT_STORAGE_TYPE='StandardLRS'
export AZURE_MGMT_DISK_SIZE='512'
export AZURE_MGMT_DISK_COUNT='1'

export AZURE_MASTER_NODE_SIZE='STANDARD_DS13' 
export AZURE_MASTER_NAME_PREFIX='master'
export AZURE_MASTER_STORAGE_TYPE='PremiumLRS'
export AZURE_MASTER_DISK_SIZE='512'
export AZURE_MASTER_DISK_COUNT='4'


export AZURE_WORKER_NODE_SIZE='STANDARD_DS13'
export AZURE_WORKER_NAME_PREFIX='worker'
export AZURE_WORKER_STORAGE_TYPE='StandardLRS'
export AZURE_WORKER_DISK_SIZE='512'
export AZURE_WORKER_DISK_COUNT='11'

export AZURE_EDGE_NODE_SIZE='STANDARD_DS13'
export AZURE_EDGE_NAME_PREFIX='edge'
export AZURE_EDGE_STORAGE_TYPE='StandardLRS'
export AZURE_EDGE_DISK_SIZE='512'
export AZURE_EDGE_DISK_COUNT='1'

export AZURE_INGEST_NODE_SIZE='STANDARD_DS13'
export AZURE_INGEST_NODE_SIZE='STANDARD_DS13'
export AZURE_INGEST_NAME_PREFIX='ingest'
export AZURE_INGEST_STORAGE_TYPE='StandardLRS'
export AZURE_INGEST_DISK_SIZE='512'
export AZURE_INGEST_DISK_COUNT='1'


export AZURE_KMS_NODE_SIZE='STANDARD_DS13'
export AZURE_KMS_NAME_PREFIX='kms'
export AZURE_KMS_STORAGE_TYPE='StandardLRS'
export AZURE_KMS_DISK_SIZE='512'
export AZURE_KMS_DISK_COUNT='1'

export DOMAIN='threeosix.lan'

export DB_TYPE='mysql'
export DB_IP='10.14.0.5'
export DB_PORT='3306'
export DB_USER='root'
export DB_PASS='cloudera'

export CDH_VERSION="5.11"
export CLUSTER_SERVICES="HDFS, YARN, ZOOKEEPER, HIVE, HUE, OOZIE, SPARK_ON_YARN, IMPALA, FLUME, SENTRY"

export CM_VERSION="5.11"
export RHEL_VERSION="7" #6|7


export CM_REPO="http://archive.cloudera.com/cm5/redhat/${RHEL_VERSION}/x86_64/cm/${CDH_VERSION}/"
export CDH_REPO="http://archive.cloudera.com/cdh5/parcels/${CDH_VERSION}/"
export CM_REPO_KEY="http://archive.cloudera.com/cm5/redhat/${RHEL_VERSION}/x86_64/cm/RPM-GPG-KEY-cloudera"



export ENVIRONMENT_NAME="DirectorEnv"
export CLOUDERA_MANAGER_NAME="CM_5_11"
export CLUSTER_NAME="Dev"

export KERBEROS_ADMIN_USER="scm@${DOMAIN^^}"
export KERBEROS_ADMIN_PASS="REPLACE-ME"
export KDC_TYPE="Active Directory"
export KDC_HOST="threeosix-dc.${DOMAIN}"
export KDC_REALM="${DOMAIN^^}"
export KDC_AD_DOMAIN="OU=Services,OU=Hadoop,dc=threeosix,dc=lan"
export KRB_ENC_TYPES="aes256-cts aes128-cts rc4-hmac"
export DNS_JOIN_USER="REPLACE-ME"
export DNS_JOIN_PASS="REPLACE-ME"

export LDAP_ADMIN_USER="ldap_bind"
export LDAP_ADMIN_PASS="REPLACE-ME"
export LDAP_URL="ldap://threeosix-dc.threeosix.lan"
export CM_ADMIN_GROUPS="hadmin_g"
export CM_USER_GROUPS="cmusers_g"
export NAV_LDAP_URL="ldap://threeosix-dc.threeosix.lan"
export NAV_ADMIN_GROUPS="hadmin_g"
export NAV_LDAP_GROUP_SEARCH_BASE="ou=Hadoop,dc=threeosix,dc=lan"
export NAV_LDAP_USER_SEARCH_BASE="ou=Hadoop,dc=threeosix,dc=lan"
export HUE_LDAP_URL="ldap://threeosix-dc.threeosix.lan"
export HUE_LDAPS_FLAG="false"
export HUE_LDAP_ADMIN_USER="${LDAP_ADMIN_USER}@${DOMAIN^^}"
export HUE_LDAP_SEARCH_BASE="ou=Hadoop,dc=threeosix,dc=lan"

awk -v CDH_REPO="${CDH_REPO}" \
    -v CLUSTER_SERVICES="${CLUSTER_SERVICES}" \
    '{
       sub(/CDH_REPO/, CDH_REPO);
       sub(/CLUSTER_SERVICES/, CLUSTER_SERVICES);
    } 1' /home/cloudera/azure_cdh.conf > /home/cloudera/azure_cdh-param.conf


export HDFS_SUPERGROUP="hadmin_g"
export HDFS_ADMIN_GROUPS="hadoop,hadmin_g"
export HDFS_ADMIN_USERS="hdfs,yarn"                        
export HDFS_AUTHORIZED_GROUPS="hadmin_g"
export HDFS_AUTHORIZED_USERS="hdfs,yarn,mapred,hive,impala,oozie,hue,zookeeper,sentry,spark,sqoop,kms,httpfs,hbase,sqoop2,flume,solr,kafka"

export HDFS_NAMESERVICE="nameservice1"

export YARN_ADMIN_ACL="yarn hadmin_g"

export SENTRY_ADMIN_GROUPS="hive,impala,hue,solr,hadmin_g"

export MASTER_HA_NODE_COUNT="2"
export MASTER_NODE_COUNT="1"
export WORKER_NODE_COUNT="3"
export GATEWAY_NODE_COUNT="1"
export KMS_NODE_COUNT="2"

#SSL
export JKS_KEYSTORE="/opt/cloudera/security/jks/keystore.jks"
export JKS_KEYSTORE_PASSWORD="cloudera"
export JKS_TRUSTSTORE="/opt/cloudera/security/jks/truststore.jks"
export JKS_TRUSTSTORE_PASSWORD="cloudera"

export PEM_KEY="/opt/cloudera/security/x509/key.pem"
export PEM_KEY_PASSWORD="cloudera"
export PEM_KEY_NOPASSWORD="/opt/cloudera/security/x509/keynopw.pem"
export PEM_CERT="/opt/cloudera/security/x509/cert.pem"
export PEM_CACERT="/opt/cloudera/security/truststore/ca-truststore.pem"

echo "You can deploy the cluster using:"
echo "cloudera-director bootstrap-remote /home/cloudera/azure_cdh-param.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189"





