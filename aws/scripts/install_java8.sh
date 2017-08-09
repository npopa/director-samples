#!/bin/bash

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -z ${JAVA_VERSION} || -z ${JAVA_HOME} || -z ${JAVA_DOWNLOAD_URL} || -z ${JCE_DOWNLOAD_URL} ]]; then 
	echo ' ${JAVA_VERSION}, ${JAVA_HOME}, ${JAVA_DOWNLOAD_URL}, ${JCE_DOWNLOAD_URL} must be defined'
	exit 1
fi

#Print params before starting
echo "JAVA_VERSION: ${JAVA_VERSION}"
echo "JAVA_HOME: ${JAVA_HOME}"
echo "JAVA_DOWNLOAD_URL: ${JAVA_DOWNLOAD_URL}"
echo "JCE_DOWNLOAD_URL: ${JCE_DOWNLOAD_URL}"


#remove any openjdk
yum remove --assumeyes *openjdk*

echo "==> Installing Java ${JAVA_VERSION} to ${JAVA_HOME}"

if [[ -d ${JAVA_HOME} ]]; then
	echo "${JAVA_VERSION} is already installed. ${JAVA_HOME} already exists. Skipping..."
else
	echo "Installing ${JAVA_VERSION}... "
	JAVA_RPM=${JAVA_DOWNLOAD_URL##*/}
	echo "Downloading ${JAVA_VERSION} from ${JAVA_DOWNLOAD_URL}"
    wget -O /tmp/${JAVA_RPM} --no-cookies --no-check-certificate --header "${ORACLE_COOKIE}" ${JAVA_DOWNLOAD_URL}
		    
	
	rpm -ivh /tmp/${JAVA_RPM}
	rm -rf /tmp/${JAVA_RPM}
	echo "Installing Java 8... Done"

	echo "Installing Java JCE 8 ... "
	JCE_FILE=${JCE_DOWNLOAD_URL##*/}	
			
	###  Install Java Unlimited Strength Encryption Policy Files for Java 8  ###
    wget -O /tmp/${JCE_FILE} --no-cookies --no-check-certificate --header "${ORACLE_COOKIE}" ${JCE_DOWNLOAD_URL} 
		
			
	unzip -jo /tmp/${JCE_FILE} -d ${JAVA_HOME}/jre/lib/security/	
	rm -rf /tmp/jce_policy-8.zip
	echo "Installing Java 8 JCE... Done"
fi
java -version




