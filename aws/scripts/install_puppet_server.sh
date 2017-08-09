#!/bin/bash

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi


#Install puppet server

rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppetserver
yum -y install puppet-agent
#clean up any openjdk dependencies
rpm -e --nodeps `yum list installed | grep openjdk | awk '{ print $1 }'`

#vi /etc/sysconfig/puppetserver #to increase memory etc.
#vi /etc/puppetlabs/puppet/puppet.conf #configuration etc.

cat <<EOF >/etc/puppetlabs/puppet/autosign.conf
*.us-west-2.compute.internal
EOF

systemctl start puppetserver
systemctl enable puppetserver


