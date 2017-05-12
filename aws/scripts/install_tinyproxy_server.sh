#!/bin/bash

#### Install tinyproxy

. /tmp/params.sh

yum -y install tinyproxy

#TODO - need to change this to dynamically find the subnet
echo "Allow 10.10.10.0/24" >> /etc/tinyproxy/tinyproxy.conf

###  Start tiny proxy and enable it on Startup  ###
systemctl start tinyproxy
systemctl enable tinyproxy



