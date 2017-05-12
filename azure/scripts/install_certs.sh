#!/bin/bash


######## Create host certificates in all formats required by CDH

###  Define Variables for your environment ###
export CERT_OUTPUT_DIR=/opt/cloudera/security
export CERT_KEY_PASS=cloudera
export CERT_SUBJ_DN_PREFIX_JKS="C=US,ST=Illinois,L=Chicago,O=Cloudera"
export CERT_ADMIN='threeosixadmin'
export CERT_ADMIN_PASS='r2OThsG12CbQtP9w3WWCM='
export DOMAIN="threeosix.lan"
export DOMAIN_CONTROLLER="threeosix-dc.${DOMAIN}"
export JAVA_HOME=/usr/java/jdk1.8.0_121-cloudera

###############################################################################


export PATH=$JAVA_HOME/bin:$PATH

#yum -y install openssl-perl

rm -rf $CERT_OUTPUT_DIR
mkdir -p $CERT_OUTPUT_DIR

ip=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')
host_name=$(hostname -s)
host_name_fqdn=$(hostname -f)

echo $host_name,$ip

mkdir -p ${CERT_OUTPUT_DIR}/jks/
mkdir -p ${CERT_OUTPUT_DIR}/x509/
mkdir -p ${CERT_OUTPUT_DIR}/ca-certs/
mkdir -p ${CERT_OUTPUT_DIR}/truststore/
mkdir -p ${CERT_OUTPUT_DIR}/csr/


curl -k -u ${CERT_ADMIN}:${CERT_ADMIN_PASS} --ntlm \
       "https://${DOMAIN_CONTROLLER}/certsrv/certnew.p7b?ReqID=CACert&Renewal=0&Enc=b64"|openssl pkcs7 -print_certs -out ${CERT_OUTPUT_DIR}/ca-certs/rootCA.pem
c_rehash ${CERT_OUTPUT_DIR}/ca-certs/

#this should be used for a CA chain
cp ${CERT_OUTPUT_DIR}/ca-certs/rootCA.pem ${CERT_OUTPUT_DIR}/truststore/ca-truststore.pem


#Import the rootCA and the intermediateCA to jseecacerts
export JSSECACERTS=${CERT_OUTPUT_DIR}/jks/jssecacerts
export JSSECACERTS_PASS=changeit
cp ${JAVA_HOME}/jre/lib/security/cacerts ${JSSECACERTS}
rm -f ${JAVA_HOME}/jre/lib/security/jssecacerts
ln -s ${JSSECACERTS} ${JAVA_HOME}/jre/lib/security/jssecacerts

keytool\
 -noprompt\
 -importcert\
 -trustcacerts\
 -alias rootCA\
 -file ${CERT_OUTPUT_DIR}/ca-certs/rootCA.pem \
 -keystore  ${JSSECACERTS}\
 -storepass ${JSSECACERTS_PASS}\
 -keypass ${JSSECACERTS_PASS}

#Generate key
keytool -genkeypair \
        -keystore ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks \
        -alias ${host_name} \
        -dname "CN=${host_name},${CERT_SUBJ_DN_PREFIX_JKS}" \
        -ext san=dns:${host_name_fqdn},ip:${ip} \
        -keyalg RSA -keysize 2048 \
        -storepass ${CERT_KEY_PASS} \
        -keypass ${CERT_KEY_PASS}

#Generate CSR
keytool -certreq \
         -alias ${host_name} \
         -keystore ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks  \
         -file ${CERT_OUTPUT_DIR}/csr/${host_name}-csr.pem \
         -ext san=dns:${host_name_fqdn},ip:${ip} \
         -storepass ${CERT_KEY_PASS} \
         -keypass ${CERT_KEY_PASS}
echo -e "\e[32mCSR... ${CERT_OUTPUT_DIR}/csr/${host_name}-csr.pem\e[0m"
openssl req -text -noout -verify \
            -in ${CERT_OUTPUT_DIR}/csr/${host_name}-csr.pem


##### Sign CSR with AD
#Adapted from: http://stackoverflow.com/questions/31283476/submitting-base64-csr-to-a-microsoft-ca-via-curl

CSR=`cat ${CERT_OUTPUT_DIR}/csr/${host_name}-csr.pem | tr -d '\n\r'`
CSR=`echo ${CSR} | sed 's/+/%2B/g'`
CSR=`echo ${CSR} | tr -s ' ' '+'`
CERTATTRIB="CertificateTemplate:Cloudera%0D%0A"

echo -e "\e[32mRequest cert...\e[0m"
OUTPUTLINK=`curl -k -u "${CERT_ADMIN}":${CERT_ADMIN_PASS} --ntlm \
"https://${DOMAIN_CONTROLLER}/certsrv/certfnsh.asp" \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.5' \
-H 'Connection: keep-alive' \
-H "Host: ${DOMAIN_CONTROLLER}" \
-H "Referer: https://${MSCA}/certsrv/certrqxt.asp" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko' \
-H 'Content-Type: application/x-www-form-urlencoded' \
--data "Mode=newreq&CertRequest=${CSR}&CertAttrib=${CERTATTRIB}&TargetStoreFlags=0&SaveCert=yes&ThumbPrint=" | grep -A 1 'function handleGetCert() {' | tail -n 1 | cut -d '"' -f 2`

CERTLINK="https://${DOMAIN_CONTROLLER}/certsrv/${OUTPUTLINK}"

echo -e "\e[32mRetrive cert: $CERTLINK\e[0m"
curl -k -u "${CERT_ADMIN}":${CERT_ADMIN_PASS} --ntlm $CERTLINK \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.5' \
-H 'Connection: keep-alive' \
-H "Host: ${DOMAIN_CONTROLLER}" \
-H "Referer: https://${MSCA}/certsrv/certrqxt.asp" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko' \
-H 'Content-Type: application/x-www-form-urlencoded' > ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem
ln -sr ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem ${CERT_OUTPUT_DIR}/x509/cert.pem

echo -e "\e[32mCert content... ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem\e[0m"
#Print cert
openssl x509 -noout -text \
     -in ${CERT_OUTPUT_DIR}/x509/cert.pem




#Export the key to pem format with and without password
keytool\
 -importkeystore\
 -srckeystore ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks \
 -srcstorepass ${CERT_KEY_PASS} \
 -srckeypass ${CERT_KEY_PASS} \
 -destkeystore ${CERT_OUTPUT_DIR}/jks/${host_name}.p12\
 -deststoretype PKCS12\
 -srcalias ${host_name}\
 -deststorepass ${CERT_KEY_PASS}\
 -destkeypass ${CERT_KEY_PASS}

openssl pkcs12\
 -in ${CERT_OUTPUT_DIR}/jks/${host_name}.p12 \
 -passin pass:${CERT_KEY_PASS}\
 -nocerts\
 -out ${CERT_OUTPUT_DIR}/x509/${host_name}-key.pem \
 -passout pass:${CERT_KEY_PASS}
ln -sr ${CERT_OUTPUT_DIR}/x509/${host_name}-key.pem ${CERT_OUTPUT_DIR}/x509/key.pem;


openssl rsa\
 -in ${CERT_OUTPUT_DIR}/x509/${host_name}-key.pem\
 -passin pass:${CERT_KEY_PASS}\
 -out ${CERT_OUTPUT_DIR}/x509/${host_name}-keynopw.pem
ln -sr ${CERT_OUTPUT_DIR}/x509/${host_name}-keynopw.pem ${CERT_OUTPUT_DIR}/x509/keynopw.pem;

rm -rf ${CERT_OUTPUT_DIR}/jks/${host_name}.p12

#Import rootCA
keytool\
 -noprompt\
 -importcert\
 -trustcacerts\
 -alias rootCA\
 -file ${CERT_OUTPUT_DIR}/ca-certs/rootCA.pem \
 -keystore  ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks\
 -storepass ${CERT_KEY_PASS}\
 -keypass ${CERT_KEY_PASS}


###Import the signed cert
keytool\
 -noprompt\
 -importcert\
 -trustcacerts\
 -alias ${host_name}\
 -file ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem\
 -keystore  ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks\
 -storepass ${CERT_KEY_PASS}\
 -keypass ${CERT_KEY_PASS}
ln -sr ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks ${CERT_OUTPUT_DIR}/jks/keystore.jks

### Build trustore
#Import rootCA and intermediateCA
keytool\
 -noprompt\
 -importcert\
 -trustcacerts\
 -alias rootCA\
 -file ${CERT_OUTPUT_DIR}/ca-certs/rootCA.pem  \
 -keystore  ${CERT_OUTPUT_DIR}/jks/truststore.jks\
 -storepass ${CERT_KEY_PASS}\
 -keypass ${CERT_KEY_PASS}


