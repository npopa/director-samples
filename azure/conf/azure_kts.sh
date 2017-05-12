#!/bin/bash

#ssh-keygen  -b 4096 -t rsa -f ~/.ssh/azure.pem -q -N "" -C "$USER@`hostname -f`"


export DIRECTOR_IP="10.14.0.5"                              
export SSH_USERNAME='cloudera'                             
export SSH_PEM_PATH='/home/cloudera/azure.pem'
export CLOUDERA_LICENSE_PATH="/home/cloudera/cdh_license.txt"

export TAGS_OWNER="owner"
export TAGS_PROJECT="KTS Cluster"

export AZURE_REGION='eastus'
export AZURE MGMT_URL='https://management.core.windows.net/'
export AZURE_AD_URL='https://login.windows.net/'
export AZURE_SUBSCRIPTION_ID='REPLACE-ME'
export AZURE_TENANT_ID='REPLACE-ME'
export AZURE_CLIENT_ID='REPLACE-ME'
export AZURE_CLIENT_SECRET='REPLACE-ME'

export AZURE_OS='redhat-rhel-72-latest'
export AZURE_NETWORK_SG_RG='user-rg'
export AZURE_NETWORK_SG='user-nsg'
export AZURE_VNET_RG='user-rg'
export AZURE_VNET='user-vnet'
export AZURE_SUBNET='user-subnet'

export AZURE_COMPUTE_RG='user-rg'
export AZURE_AVAILABILITY_SET='user-hadoop'
export AZURE_PUBLIC_IP='No'

export AZURE_KTS_NODE_SIZE='STANDARD_DS13'
export AZURE_KTS_NAME_PREFIX='kts'
export AZURE_KTS_STORAGE_TYPE='StandardLRS'
export AZURE_KTS_DISK_SIZE='512'
export AZURE_KTS_DISK_COUNT='1'

export DOMAIN='threeosix.lan'


export CLUSTER_SERVICES="DUMMY"


export ENVIRONMENT_NAME="DirectorEnv"
export CLOUDERA_MANAGER_NAME="CM_5_11"
export CLUSTER_NAME="KTS"

export KERBEROS_ADMIN_USER="scm@${DOMAIN^^}"
export KERBEROS_ADMIN_PASS="REPLACE-ME"
export KDC_TYPE="Active Directory"
export KDC_HOST="threeosix-dc.${DOMAIN}"
export KDC_REALM="${DOMAIN^^}"
export KDC_AD_DOMAIN="OU=Services,OU=Hadoop,dc=threeosix,dc=lan"
export KRB_ENC_TYPES="aes256-cts aes128-cts arcfour-hmac"
export DNS_JOIN_USER="REPLACE-ME" 
export DNS_JOIN_PASS="REPLACE-ME"

awk -v CDH_REPO="${CDH_REPO}" \
    -v CLUSTER_SERVICES="${CLUSTER_SERVICES}" \
    '{
       sub(/CDH_REPO/, CDH_REPO);
       sub(/CLUSTER_SERVICES/, CLUSTER_SERVICES);
    } 1' /home/cloudera/azure_kts.conf > /home/cloudera/azure_kts-param.conf


export KTS_NODE_COUNT="2"

#cloudera-director bootstrap-remote /home/cloudera/azure_kts-param.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189





