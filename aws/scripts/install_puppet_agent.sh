#!/bin/bash

### Add kerberos principals for some users

. /tmp/params.sh

###Puppet Agent
sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet-agent

export PUBLIC_HOSTNAME=$(curl http://169.254.169.254/2016-09-02/meta-data/public-hostname)
export PUBLIC_IP=$(curl http://169.254.169.254/2016-09-02/meta-data/public-ipv4)
export LOCAL_IP=$(curl http://169.254.169.254/2016-09-02/meta-data/local-ipv4)
cat <<EOF >/etc/puppetlabs/puppet/puppet.conf

[main]
server = ${PUPPET_HOST}
environment = production
runinterval = 1h

[agent]
#dns_alt_names = ${PUBLIC_HOSTNAME}

EOF

sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true