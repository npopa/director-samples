#!/bin/bash

. ./aws.sh #this should load the credentials. Else they can be defined here inline as below:
export AWS_KEY_ID=${AWS_KEY_ID}
export AWS_SECRET_KEY=${AWS_SECRET_KEY}
export AWS_REGION=${AWS_REGION} #"us-west-2"
export AWS_SUBNET_ID=${AWS_SUBNET_ID} #"subnet-xyz"
export AWS_SECURITY_GROUP_ID=${AWS_SECURITY_GROUP_ID} #"sg-xyz"
export AWS_AMI_ID=${AWS_AMI_ID} #"ami-30697651"
export SSH_USERNAME=${SSH_USERNAME} #ec2-user
export SSH_PEM_PATH=${SSH_PEM_PATH} #"/home/ec2-user/mykey.pem"
#### End AWS settings


export CLUSTER_NAME="mypoc"
export ENVIRONMENT_NAME="Development"
export CLOUDERA_MANAGER_NAME="CM511"
export CLUSTER_OWNER="npopa"
export AWS_INSTANCE_PREFIX="${CLUSTER_NAME}"

#There are three masters
export WORKER_NODE_COUNT="3"
export EDGE_NODE_COUNT="1"
export KAFKA_NODE_COUNT="1"
export KMS_NODE_COUNT="0"
export KTS_NODE_COUNT="0"



export RHEL_VERSION="7" #6|7
export CM_VERSION="5.11.0"
export CDH_VERSION="5.11.0"
export KUDU_VERSION="1.3.0"
export SPARK2_VERSION="2.1.0.cloudera1"
export KAFKA_VERSION="2.1.1"

export CM_REPO="http://archive.cloudera.com/cm5/redhat/${RHEL_VERSION}/x86_64/cm/${CDH_VERSION}/"
export CM_REPO_KEY="http://archive.cloudera.com/cm5/redhat/${RHEL_VERSION}/x86_64/cm/RPM-GPG-KEY-cloudera"

export CDH_REPO="http://archive.cloudera.com/cdh5/parcels/${CDH_VERSION}/"
export KUDU_REPO="http://archive.cloudera.com/kudu/parcels/${CDH_VERSION}/"
export SPARK2_REPO="http://archive.cloudera.com/spark2/parcels/${SPARK2_VERSION}/"
export KAFKA_REPO="http://archive.cloudera.com/kafka/parcels/${KAFKA_VERSION}/"

export DIRECTOR_IP=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')


#####mysql stuff 
export DB_TYPE="mysql"
export DB_IP=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')
export DB_HOST=$(hostname -f)
export DB_PORT='3306'
export DB_USER="root"
export DB_PASS="cloudera"


export KDC_TYPE="MIT KDC"
export KDC_HOST=$(hostname -f)
export KDC_REALM="THREEOSIX.LAN"
export KERBEROS_ADMIN_USER="scm/admin@THREEOSIX.LAN"
export KERBEROS_ADMIN_PASS="cloudera"
export KRB_ENC_TYPES="aes256-cts arcfour-hmac"



export LDAP_ADMIN_USER="ldap_bind"
export LDAP_ADMIN_PASS="Cl0ud3ra"
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

export HDFS_SUPERGROUP="hadmin_g"
export HDFS_ADMIN_GROUPS="hadoop,hadmin_g"
export HDFS_ADMIN_USERS="hdfs,yarn"                        
export HDFS_AUTHORIZED_GROUPS="hadmin_g"
export HDFS_AUTHORIZED_USERS="hdfs,yarn,mapred,hive,impala,oozie,hue,zookeeper,sentry,spark,sqoop,kms,httpfs,hbase,sqoop2,flume,solr,kafka"

export HDFS_NAMESERVICE="nameservice1"

export YARN_ADMIN_ACL="yarn hadmin_g"

export SENTRY_ADMIN_GROUPS="hive,impala,hue,solr,kafka,hadmin_g"


export YARN_ADMIN_GROUPS="yarn"

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

echo "Updating Director host to: $(hostname -f)"
sed -i "s/DIRECTOR_HOST=.*/DIRECTOR_HOST=$(hostname -f)/g" ./params.sh

#cleaning certificates
sudo sh -c "/opt/puppetlabs/bin/puppet cert list --all|cut -d' ' -f2|grep -v $(hostname -f)|xargs /opt/puppetlabs/bin/puppet cert clean"


echo "You can deploy the cluster using:"
echo cloudera-director bootstrap-remote ~/cdh_full.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189
#echo "or, if the CM/CDH is already installed you can deploy Kafka with:"
#echo cloudera-director bootstrap-remote ~/aws_cdh_kafka.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189


#'red': '\033[0;31m'
#'nocolor': '\033[0m'
