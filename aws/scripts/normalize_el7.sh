#!/bin/bash

#Normalize instnace
#TODO - keep adding common stuff here

. /tmp/params.sh

#Add proxy settings



###  Ensure the Node and YUM are up to date.  ###
yum clean all
yum makecache fast
yum -y update

#Install some utilities
yum install -y wget unzip bind-utils openssl-perl

#Disable SElinux
getenforce
sed -e 's/^SELINUX=enforcing/SELINUX=disabled/' -i /etc/selinux/config
sed -e 's/^SELINUX=permissive/SELINUX=disabled/' -i /etc/selinux/config
setenforce 0
getenforce

###  Disable tuned so it does not overwrite sysctl.conf  ###
systemctl stop tuned
systemctl disable tuned

###  Disable chrony so it does not conflict with ntpd installed by Director  ###
systemctl stop chronyd
systemctl disable chronyd

###  Disable cups ###
systemctl stop cups
systemctl disable cups

###  Disable postfix ###
systemctl stop postfix
systemctl disable postfix

### Disable transparent huge pages ###
grep -i HugePages_Total /proc/meminfo 
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local

### Set swappiness ###
echo "vm.swappiness = 1" >> /etc/sysctl.conf
echo "* - nofile 32768" > /etc/security/limits.d/90-nofile.conf


###  Update config to disable IPv6 and disable  ###
echo "# Disable IPv6" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

###  Turn off firewall  ###
systemctl stop firewalld
systemctl disable firewalld

###  Turn on NTP  ###
yum install -y ntp

systemctl start ntpd
systemctl enable ntpd
ntpq -p

#	   server 0.us.pool.ntp.org
#	   server 1.us.pool.ntp.org
#	   server 2.us.pool.ntp.org
#	   server 3.us.pool.ntp.org

###  Update Timezone  ###
timedatectl set-timezone America/Chicago

#make sure we have enough entropy
cat /proc/sys/kernel/random/entropy_avail

yum install -y rng-tools
cp /usr/lib/systemd/system/rngd.service /etc/systemd/system/
sed -i -e 's/ExecStart=\/sbin\/rngd -f/ExecStart=\/sbin\/rngd -f -r \/dev\/urandom/' /etc/systemd/system/rngd.service
systemctl daemon-reload
systemctl start rngd
systemctl enable rngd

yum install -y haveged
systemctl start haveged
systemctl enable haveged

cat /proc/sys/kernel/random/entropy_avail


# Poke sysctl to have it pickup the config change.
sysctl -p



#hdd="/dev/vdc /dev/vdd /dev/vde /dev/vdf"
#for i in $hdd;do
#echo -e "o\nn\np\n1\n\n\nw" | fdisk $i
#mkfs.ext4 ${i}1
#done


#Simulate 4 disks
sudo mkdir -p /mnt/data0
#sudo mkdir -p /mnt/data1
#sudo mkdir -p /mnt/data2
#sudo mkdir -p /mnt/data3
sudo ln -s /mnt/data0 /data0
#sudo ln -s /mnt/data1 /data1
#sudo ln -s /mnt/data2 /data2
#sudo ln -s /mnt/data3 /data3   

