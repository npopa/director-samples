#!/bin/bash 

#Install CM

wget http://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo

#CM
yum install -y cloudera-manager-daemons cloudera-manager-server cloudera-manager-agent


export JAVA_HOME='/usr/java/jdk1.8.0_121'
export PATH=$JAVA_HOME/bin:$PATH
/usr/share/cmf/schema/scm_prepare_database.sh mysql scm scm scm

systemctl start cloudera-scm-server
systemctl enable cloudera-scm-server


#install agent
#wget http://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo
#yum install -y cloudera-manager-agent

#install parcel
#wget http://archive.cloudera.com/cdh5/parcels/5.11/CDH-5.11.0-1.cdh5.11.0.p0.34-el7.parcel -O /opt/cloudera/tmp/CDH-5.11.0-1.cdh5.11.0.p0.34-el7.parcel
#wget http://archive.cloudera.com/cdh5/parcels/5.11/CDH-5.11.0-1.cdh5.11.0.p0.34-el7.parcel.sha1 /opt/cloudera/tmp/CDH-5.11.0-1.cdh5.11.0.p0.34-el7.parcel.sha1
#wget http://archive.cloudera.com/cdh5/parcels/5.11/manifest.json /opt/cloudera/tmp/manifest.json
#python -m SimpleHTTPServer 8080


