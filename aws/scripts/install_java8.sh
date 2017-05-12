#!/bin/bash

#remove any openjdk
yum remove --assumeyes *openjdk*

export JAVA_HOME='/usr/java/jdk1.8.0_121'

if [[ -d ${JAVA_HOME} ]]; then
	echo "jdk1.8.0_121 already installed. Skipping."
else
	echo "Installing Java 8... "

	wget --no-cookies --no-check-certificate \
	        --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
	         "http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.rpm" \
	         -O /tmp/jdk-8u121-linux-x64.rpm

	rpm -ivh /tmp/jdk-8u121-linux-x64.rpm


	rm -rf /tmp/jdk-8u121-linux-x64.rpm
	echo "Installing Java 8... Done"

	echo "Installing Java 8 JCE... "
	###  Install Java Unlimited Strength Encryption Policy Files for Java 8  ###
	wget -O /tmp/jce_policy-8.zip --no-cookies --no-check-certificate \
	      --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
	      "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
	unzip -o /tmp/jce_policy-8.zip -d /tmp
	rm -f ${JAVA_HOME}/jre/lib/security/local_policy.jar
	rm -f ${JAVA_HOME}/jre/lib/security/US_export_policy.jar
	mv /tmp/UnlimitedJCEPolicyJDK8/local_policy.jar ${JAVA_HOME}/jre/lib/security/local_policy.jar
	mv /tmp/UnlimitedJCEPolicyJDK8/US_export_policy.jar ${JAVA_HOME}/jre/lib/security/US_export_policy.jar

	rm -rf /tmp/jce_policy-8.zip
	rm -rf /tmp/UnlimitedJCEPolicyJDK8
	echo "Installing Java 8 JCE... Done"
fi
java -version





