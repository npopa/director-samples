#!/bin/bash

#Normalize instnace
#TODO - keep adding common stuff here
env|sort

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi


#Install some packages if they are not already installed
yum install -y wget unzip bzip2 bind-utils

echo '==> Disabling SElinux'
#Disable SElinux
getenforce
sed -e 's/^SELINUX=enforcing/SELINUX=disabled/' -i /etc/selinux/config
sed -e 's/^SELINUX=permissive/SELINUX=disabled/' -i /etc/selinux/config
setenforce 0
getenforce

echo '==> Disabling tuned'
###  Disable tuned so it does not overwrite sysctl.conf  ###
systemctl stop tuned
systemctl disable tuned

echo '==> Disabling chronyd'
###  Disable chrony so it does not conflict with ntpd installed by Director  ###
systemctl stop chronyd
systemctl disable chronyd

echo '==> Disabling cups'
###  Disable cups ###
systemctl stop cups
systemctl disable cups

echo '==> Disabling postfix'
###  Disable postfix ###
systemctl stop postfix
systemctl disable postfix

echo '==> Disabling THP'
### Disable transparent huge pages ###
grep -i HugePages_Total /proc/meminfo
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.local
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local

echo '==> Setting swappiness to 1'
### Set swappiness ###
echo "vm.swappiness = 1" >> /etc/sysctl.conf

echo '==> Increasing nofile limits'
echo "* - nofile 32768" > /etc/security/limits.d/90-nofile.conf

echo '==> Disabling IPv6'
###  Update config to disable IPv6 and disable  ###
echo "# Disable IPv6" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

echo '==> Disabling firewalld'
###  Turn off firewall  ###
systemctl stop firewalld
systemctl disable firewalld

echo '==> Installing ntp'
###  Turn on NTP  ###
yum install -y ntp
systemctl start ntpd
systemctl enable ntpd
ntpq -p
###  Update Timezone  ###
timedatectl set-timezone America/Chicago


echo '==> Installing rngd'
#make sure we have enough entropy
yum install -y rng-tools
sed -i -e 's/ExecStart=\/sbin\/rngd -f/ExecStart=\/sbin\/rngd -f -r \/dev\/urandom/' /etc/systemd/system/rngd.service
systemctl start rngd
systemctl enable rngd

echo '==> Installing haveged'
yum install -y haveged
systemctl start haveged
systemctl enable haveged	
sleep 1
echo "==> Entropy now is $(cat /proc/sys/kernel/random/entropy_avail)"


# Poke sysctl to have it pickup the config change.
sysctl -p

#add entry for the hostname
#HOST_IP=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')
HOST_IP=$(hostname -I | cut -d" " -f 1)
echo "#${HOST_IP}  $(hostname -f)  $(hostname -s)">> /etc/hosts

echo '==> Verifying forward and reverse DNS lookup'
echo $(/bin/host $(hostname -f))
echo $(/bin/host $(hostname -i))

#Disable NetworkManager so it does not change settings
#echo '==> Disabling NetworkManager'
#systemctl stop NetworkManager
#systemctl disable NetworkManager

echo '==> Creating datadirs'
#disks
sudo mkdir -p /mnt/data0
#sudo mkdir -p /mnt/data1
#sudo mkdir -p /mnt/data2
#sudo mkdir -p /mnt/data3
sudo ln -s /mnt/data0 /data0
#sudo ln -s /mnt/data1 /data1
#sudo ln -s /mnt/data2 /data2
#sudo ln -s /mnt/data3 /data3   

