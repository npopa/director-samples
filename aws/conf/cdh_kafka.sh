#!/bin/bash


if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -f ~/.aws.sh ]]; then 
	source  ~/.aws.sh
else
	cat <<'EOF'
File  ~/.aws.sh is missing. Create one with the below content: 
export AWS_KEY_ID=${AWS_KEY_ID}
export AWS_SECRET_KEY=${AWS_SECRET_KEY}
export AWS_REGION=${AWS_REGION} #"us-west-2"
export AWS_SUBNET_ID=${AWS_SUBNET_ID} #"subnet-xyz"
export AWS_SECURITY_GROUP_ID=${AWS_SECURITY_GROUP_ID} #"sg-xyz"
export AWS_AMI_ID=${AWS_AMI_ID} #"ami-30697651"
export SSH_USERNAME=${SSH_USERNAME} #ec2-user
export SSH_PEM_PATH=${SSH_PEM_PATH} #"/home/ec2-user/mykey.pem"
#### End AWS settings
EOF
fi

export CLUSTER_NAME="Kafka211"
export ENVIRONMENT_NAME="Development"
export CLOUDERA_MANAGER_NAME="CM511"
export CLUSTER_OWNER="npopa"
export AWS_INSTANCE_PREFIX="${CLUSTER_NAME}"

#Kafka brokers
export KAFKA_NODE_COUNT="3"

export RHEL_VERSION="7" #6|7
export KAFKA_VERSION="2.1.1"
export KAFKA_REPO="http://archive.cloudera.com/kafka/parcels/${KAFKA_VERSION}/"

echo "Updating Director host to: $(hostname -f)"
sed -i "s/DIRECTOR_HOST=.*/DIRECTOR_HOST=$(hostname -f)/g" ./params.sh


echo "You can deploy the cluster using:"
echo cloudera-director bootstrap-remote ~/cdh_full.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189
echo "or, if the CM/CDH is already installed you can deploy Kafka with:"
echo cloudera-director bootstrap-remote ~/cdh_kafka.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189


#'red': '\033[0;31m'
#'nocolor': '\033[0m'
