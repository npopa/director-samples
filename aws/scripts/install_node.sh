#!/bin/bash 

##Build node

sudo fdisk -l
df -Ph 
mount 


sudo yum clean all
sudo yum makecache fast
sudo yum -y update

#Install some utilities
sudo yum install -y wget unzip bind-utils openssl-perl screen

#Disable SElinux
sudo getenforce
sudo sed -e 's/^SELINUX=enforcing/SELINUX=disabled/' -i /etc/selinux/config
sudo sed -e 's/^SELINUX=permissive/SELINUX=disabled/' -i /etc/selinux/config
sudo setenforce 0
sudo getenforce

###  Disable tuned so it does not overwrite sysctl.conf  ###
sudo systemctl stop tuned
sudo systemctl disable tuned

###  Disable chrony so it does not conflict with ntpd installed by Director  ###
sudo systemctl stop chronyd
sudo systemctl disable chronyd

###  Disable cups ###
sudo systemctl stop cups
sudo systemctl disable cups

###  Disable postfix ###
sudo systemctl stop postfix
sudo systemctl disable postfix

### Disable transparent huge pages ###
sudo grep -i HugePages_Total /proc/meminfo 
sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag"
sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
sudo sh -c 'echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local'
sudo sh -c 'echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local'

### Set swappiness ###
sudo sh -c 'echo "vm.swappiness = 1" >> /etc/sysctl.conf'
sudo sh -c 'echo "* - nofile 32768" > /etc/security/limits.d/90-nofile.conf'


###  Update config to disable IPv6 and disable  ###
sudo sh -c 'echo "# Disable IPv6" >> /etc/sysctl.conf'
sudo sh -c 'echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf'
sudo sh -c 'echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf'

###  Turn off firewall  ###
sudo systemctl stop firewalld
sudo systemctl disable firewalld

###  Turn on NTP  ###
sudo yum install -y ntp

sudo systemctl start ntpd
sudo systemctl enable ntpd
sudo ntpq -p

#      server 0.us.pool.ntp.org
#      server 1.us.pool.ntp.org
#      server 2.us.pool.ntp.org
#      server 3.us.pool.ntp.org

###  Update Timezone  ###
sudo timedatectl set-timezone America/Chicago

#make sure we have enough entropy
sudo cat /proc/sys/kernel/random/entropy_avail

sudo yum install -y rng-tools
sudo cp /usr/lib/systemd/system/rngd.service /etc/systemd/system/
sudo sed -i -e 's/ExecStart=\/sbin\/rngd -f/ExecStart=\/sbin\/rngd -f -r \/dev\/urandom/' /etc/systemd/system/rngd.service
sudo systemctl daemon-reload
sudo systemctl start rngd
sudo systemctl enable rngd

sudo yum install -y haveged
sudo systemctl start haveged
sudo systemctl enable haveged

sudo cat /proc/sys/kernel/random/entropy_avail


# Poke sysctl to have it pickup the config change.
sudo sysctl -p


export JAVA_HOME='/usr/java/jdk1.8.0_121'
if [[ -d ${JAVA_HOME} ]]; then
    echo "jdk1.8.0_121 already installed. Skipping."
else
    echo "Installing Java 8... "

    #remove any openjdk
    sudo yum remove --assumeyes *openjdk*

    sudo wget --no-cookies --no-check-certificate \
            --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
             "http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.rpm" \
             -O /tmp/jdk-8u121-linux-x64.rpm

    sudo rpm -ivh /tmp/jdk-8u121-linux-x64.rpm


    sudo rm -rf /tmp/jdk-8u121-linux-x64.rpm
    sudo echo "Installing Java 8... Done"

    sudo echo "Installing Java 8 JCE... "
    ###  Install Java Unlimited Strength Encryption Policy Files for Java 8  ###
    sudo wget -O /tmp/jce_policy-8.zip --no-cookies --no-check-certificate \
          --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
          "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
    sudo unzip -o /tmp/jce_policy-8.zip -d /tmp
    sudo rm -f ${JAVA_HOME}/jre/lib/security/local_policy.jar
    sudo rm -f ${JAVA_HOME}/jre/lib/security/US_export_policy.jar
    sudo mv /tmp/UnlimitedJCEPolicyJDK8/local_policy.jar ${JAVA_HOME}/jre/lib/security/local_policy.jar
    sudo mv /tmp/UnlimitedJCEPolicyJDK8/US_export_policy.jar ${JAVA_HOME}/jre/lib/security/US_export_policy.jar

    sudo rm -rf /tmp/jce_policy-8.zip
    sudo rm -rf /tmp/UnlimitedJCEPolicyJDK8
    echo "Installing Java 8 JCE... Done"
fi 
java -version

if [[ -f /usr/share/java/mysql-connector-java-5.1.40-bin.jar ]]; then
    echo "mysql-connector-java-5.1.40 already installed. Skipping."
else
    echo "Installing mysql-connector-java"
    sudo wget "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz" -O /tmp/mysql-connector-java-5.1.40.tar.gz
    sudo tar zxvf /tmp/mysql-connector-java-5.1.40.tar.gz -C /tmp/
    sudo mkdir -p /usr/share/java/
    sudo cp /tmp/mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /usr/share/java/
    sudo rm /usr/share/java/mysql-connector-java.jar
    sudo ln -s /usr/share/java/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar
fi

sudo yum install -y krb5-pkinit-openssl krb5-server-ldap words krb5-workstation cyrus-sasl-gssapi pam_krb5 

sudo yum install -y sssd oddjob oddjob-mkhomedir openldap-devel pam_krb5 cyrus-sasl-gssapi authconfig
sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet-agent

#Install latest CM version
sudo wget http://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo
sudo yum install -y cloudera-manager-daemons  cloudera-manager-agent
sudo yum install -y cloudera-manager-server

# Disable the automatic starting of Cloudera Manager. Director will handle this.
echo "Disabling Cloudera Manager"
sudo systemctl disable cloudera-scm-agent
sudo systemctl disable cloudera-scm-server






#Parcels

sudo useradd -r cloudera-scm
sudo rm -rf /opt/cloudera/parcels /opt/cloudera/parcel-repo /opt/cloudera/parcel-cache

sudo mkdir -p /opt/cloudera/parcels /opt/cloudera/parcel-repo /opt/cloudera/parcel-cache

export CDH_PARCEL="http://archive.cloudera.com/cdh5/parcels/5.11.0/CDH-5.11.0-1.cdh5.11.0.p0.34-el7.parcel"
export KUDU_PARCEL="http://archive.cloudera.com/kudu/parcels/5.11.0/KUDU-1.3.0-1.cdh5.11.0.p0.12-el7.parcel"
export SPARK2_PARCEL="http://archive.cloudera.com/spark2/parcels/2.1.0/SPARK2-2.1.0.cloudera1-1.cdh5.7.0.p0.120904-el7.parcel"
export KAFKA_PARCEL="http://archive.cloudera.com/kafka/parcels/2.1.1/KAFKA-2.1.1-1.2.1.1.p0.18-el7.parcel"

export PARCELS="${CDH_PARCEL} ${KUDU_PARCEL} ${SPARK2_PARCEL} ${KAFKA_PARCEL}"

for PARCEL_URL in ${PARCELS}; do
    PARCEL_NAME="${PARCEL_URL##*/}"

    echo "Downloading parcel from $PARCEL_URL"
    sudo curl -s -S "${PARCEL_URL}" -o "/opt/cloudera/parcel-repo/$PARCEL_NAME"
    sudo curl -s -S "${PARCEL_URL}.sha1" -o "/opt/cloudera/parcel-repo/$PARCEL_NAME.sha1"
    sudo cp "/opt/cloudera/parcel-repo/$PARCEL_NAME.sha1" "/opt/cloudera/parcel-repo/$PARCEL_NAME.sha"

    echo "Verifying parcel checksum"
    sudo sed "s/$/  ${PARCEL_NAME}/" "/opt/cloudera/parcel-repo/$PARCEL_NAME.sha1" |
      sudo tee "/opt/cloudera/parcel-repo/$PARCEL_NAME.shacheck" > /dev/null
    if ! eval "cd /opt/cloudera/parcel-repo && sha1sum -c \"$PARCEL_NAME.shacheck\""; then
      echo "Checksum verification failed"
      exit 1    
    fi
    sudo rm "/opt/cloudera-scmera/parcel-repo/$PARCEL_NAME.shacheck"

done


for parcel_path in /opt/cloudera/parcel-repo/*.parcel
do
    parcel=$(basename "$parcel_path")
    short_name=$(echo ${parcel}|cut -d"-" -f1)
    sudo ln "$parcel_path" "/opt/cloudera/parcel-cache/${parcel}"
    sudo tar zxf ${parcel_path} -C "/opt/cloudera/parcels"
    sudo ln -s "$(ls -1 /opt/cloudera/parcels/|grep ${short_name})" /opt/cloudera/parcels/${short_name}
    sudo touch /opt/cloudera/parcels/${short_name}/.dont_delete

done
sudo chown -R cloudera-scm:cloudera-scm /opt/cloudera

echo "Sync Linux volumes with EBS."
sudo sync
sleep 5



