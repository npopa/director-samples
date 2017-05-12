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


export CLUSTER_NAME="mypoc-kafka"
export ENVIRONMENT_NAME="Development"
export CLOUDERA_MANAGER_NAME="CM511"
export CLUSTER_OWNER="npopa"
export AWS_INSTANCE_PREFIX="${CLUSTER_NAME}"

#There are three masters
export KAFKA_NODE_COUNT="3"

export RHEL_VERSION="7" #6|7
export KAFKA_VERSION="2.1.1"
export KAFKA_REPO="http://archive.cloudera.com/kafka/parcels/${KAFKA_VERSION}/"

export DIRECTOR_IP=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')

export SENTRY_ADMIN_GROUPS="hive,impala,hue,solr,kafka,hadmin_g"

#SSL
export JKS_KEYSTORE="/opt/cloudera/security/jks/keystore.jks"
export JKS_KEYSTORE_PASSWORD="cloudera"
export JKS_TRUSTSTORE="/opt/cloudera/security/jks/truststore.jks"
export JKS_TRUSTSTORE_PASSWORD="cloudera"

echo "Updating Director host to: $(hostname -f)"
sed -i "s/DIRECTOR_HOST=.*/DIRECTOR_HOST=$(hostname -f)/g" ./params.sh


echo "You can deploy the cluster using:"
echo cloudera-director bootstrap-remote ~/cdh_full.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189
echo "or, if the CM/CDH is already installed you can deploy Kafka with:"
echo cloudera-director bootstrap-remote ~/cdh_kafka.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189


#'red': '\033[0;31m'
#'nocolor': '\033[0m'
