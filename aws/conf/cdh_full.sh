#!/bin/bash

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
else
	echo "/tmp/params.sh not found!"
	exit 1
fi

if [[ -f /tmp/groups.sh ]]; then 
	source /tmp/groups.sh
else
	echo "/tmp/groups.sh not found!"
	exit 1
fi

if [[ -f ~/.aws.sh ]]; then 
	source  ~/.aws.sh
else
	cat <<EOF
File  ~/.aws.sh is missing. Create one with content similar to below: 
export AWS_KEY_ID=""
export AWS_SECRET_KEY=""
export AWS_REGION="us-west-2"
export AWS_SUBNET_ID="subnet-xyz"
export AWS_SECURITY_GROUP_ID="sg-xyz"
export AWS_AMI_ID="ami-30697651"
export SSH_USERNAME=ec2-user
export SSH_PEM_PATH="/home/ec2-user/mykey.pem"
#### End AWS settings
EOF
fi

export CLUSTER_NAME="CDH"
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

export HDFS_NAMESERVICE="nameservice1"
export HDFS_SUPERGROUP=$(echo $HDFS_ADMIN_GROUP|cut -f2 -d"("|tr -d ")")
export YARN_ADMIN_ACL="yarn $(echo $YARN_ADMIN_GROUP|cut -f2 -d"("|tr -d ")")"
export SENTRY_ADMIN_GROUPS="hive,impala,hue,solr,kafka,$(echo $SENTRY_ADMIN_GROUP|cut -f2 -d"("|tr -d ")")"


#cleaning certificates
sudo sh -c "/opt/puppetlabs/bin/puppet cert list --all|cut -d' ' -f2|grep -v $(hostname -f)|xargs /opt/puppetlabs/bin/puppet cert clean"
sed -i "s/DIRECTOR_HOST=.*/DIRECTOR_HOST=$(hostname -f)/g" ../scripts/params.sh


echo "You can deploy the cluster using:"
echo cloudera-director bootstrap-remote cdh_full.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=$(hostname -f):7189

#'red': '\033[0;31m'
#'nocolor': '\033[0m'
