#!/bin/bash


#Builds a structure similar to below:

#[root@ip-10-10-10-116 security]# tree /opt/cloudera/security/
#/opt/cloudera/security/
#├── ca-certs
#│   ├── 4e64413f.0 -> rootCA.pem
#│   └── rootCA.pem
#├── csr
#├── jks
#│   ├── ip-10-10-10-116-keystore.jks
#│   ├── jssecacerts
#│   ├── keystore.jks -> ip-10-10-10-116-keystore.jks
#│   └── truststore.jks
#├── truststore
#│   └── ca-truststore.pem
#└── x509
#    ├── cert.pem -> ip-10-10-10-116-cert.pem
#    ├── ip-10-10-10-116-cert.pem
#    ├── ip-10-10-10-116-keynopw.pem
#    ├── ip-10-10-10-116-key.pem
#    ├── keynopw.pem -> ip-10-10-10-116-keynopw.pem
#    └── key.pem -> ip-10-10-10-116-key.pem

. /tmp/params.sh

rm -rf $CERT_OUTPUT_DIR
mkdir -p $CERT_OUTPUT_DIR

ip=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')
host_name=$(hostname -s)
host_name_fqdn=$(hostname -f)

mkdir -p ${CERT_OUTPUT_DIR}/jks/
mkdir -p ${CERT_OUTPUT_DIR}/x509/
mkdir -p ${CERT_OUTPUT_DIR}/ca-certs/
mkdir -p ${CERT_OUTPUT_DIR}/truststore/
mkdir -p ${CERT_OUTPUT_DIR}/csr/

cp ${PUPPET_SSL_HOME}/certs/ca.pem ${CERT_OUTPUT_DIR}/ca-certs/rootCA.pem
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

cat ${PUPPET_SSL_HOME}/certs/${host_name_fqdn}.pem > ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem
rm -rf ${CERT_OUTPUT_DIR}/x509/cert.pem
ln -sr ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem ${CERT_OUTPUT_DIR}/x509/cert.pem

echo -e "\e[32mCert content... ${CERT_OUTPUT_DIR}/x509/cert.pem\e[0m"
#Print cert
openssl x509 -noout -text \
     -in ${CERT_OUTPUT_DIR}/x509/cert.pem

echo -e "\e[32mCert md5... ${CERT_OUTPUT_DIR}/x509/cert.pem\e[0m"
openssl x509 -noout -modulus -in ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem | openssl md5


cat ${PUPPET_SSL_HOME}/private_keys/${host_name_fqdn}.pem > ${CERT_OUTPUT_DIR}/x509/${host_name}-keynopw.pem
rm -rf ${CERT_OUTPUT_DIR}/x509/keynopw.pem
ln -sr ${CERT_OUTPUT_DIR}/x509/${host_name}-keynopw.pem ${CERT_OUTPUT_DIR}/x509/keynopw.pem
echo -e "\e[32mKey content... ${CERT_OUTPUT_DIR}/x509/keynopw.pem\e[0m"
#Print key
openssl rsa -in ${CERT_OUTPUT_DIR}/x509/keynopw.pem -noout -text

echo -e "\e[32mKey md5... ${CERT_OUTPUT_DIR}/x509/keynopw.pem\e[0m"
openssl rsa -modulus -noout -in ${CERT_OUTPUT_DIR}/x509/keynopw.pem | openssl md5

openssl rsa\
 -in ${CERT_OUTPUT_DIR}/x509/${host_name}-keynopw.pem \
 -out ${CERT_OUTPUT_DIR}/x509/${host_name}-key.pem \
 -passout pass:${CERT_KEY_PASS}
ln -sfr ${CERT_OUTPUT_DIR}/x509/${host_name}-key.pem ${CERT_OUTPUT_DIR}/x509/key.pem



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

###This could be another method to import the signed cert and its key. Not tested.
#cat ${CERT_OUTPUT_DIR}/x509/cert.pem ${CERT_OUTPUT_DIR}/x509/key.pem>/tmp/combined.pem
#keytool\
# -noprompt\
# -import\
# -trustcacerts\
# -alias ${host_name}\
# -file /tmp/combined.pem\
# -keystore  ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks\
# -storepass ${CERT_KEY_PASS}\
# -keypass ${CERT_KEY_PASS}


###Import private key and certificate
openssl pkcs12 -export -in ${CERT_OUTPUT_DIR}/x509/${host_name}-cert.pem\
               -inkey ${CERT_OUTPUT_DIR}/x509/keynopw.pem \
               -name ${host_name} \
               -passout pass:${CERT_KEY_PASS}\
               -out ${CERT_OUTPUT_DIR}/jks/${host_name}-p12.p12

###Import the signed p12 cert
keytool\
 -noprompt\
 -importkeystore\
 -trustcacerts\
 -alias ${host_name}\
 -srckeystore ${CERT_OUTPUT_DIR}/jks/${host_name}-p12.p12\
 -srckeypass ${CERT_KEY_PASS}\
 -srcstorepass ${CERT_KEY_PASS}\
 -srcstoretype pkcs12\
 -keystore  ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks\
 -storepass ${CERT_KEY_PASS}\
 -keypass ${CERT_KEY_PASS}
rm -rf ${CERT_OUTPUT_DIR}/jks/${host_name}-p12.p12
ln -sfr ${CERT_OUTPUT_DIR}/jks/${host_name}-keystore.jks ${CERT_OUTPUT_DIR}/jks/keystore.jks


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




