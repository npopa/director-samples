#!/bin/sh

#
# This script will bootstrap these OSes:
#   - RHEL 7.2
#


###  Define Variables for your environment ###
DOMAIN="threeosix.lan"
DOMAIN_CONTROLLER="threeosix-dc.${DOMAIN}"
DNS_IP=${DOMAIN_CONTROLLER}
AD_JOIN_USER="REPLACE_ME"
AD_JOIN_PASS="REPLACE_ME"
DNS_JOIN_USER="REPLACE_ME"
DNS_JOIN_PASS="REPLACE_ME"
COMPUTER_OU="OU=Servers,OU=Hadoop,DC=threeosix,DC=lan"




###############################################################################

HOST_IP_ADDRESS=$(ip addr | grep eth0 -A2 | head -n3 | tail -n1 | awk -F'[/ ]+' '{print $3}')
HOSTNAME=$(hostname)

#
# Functions
#

# writing network manager hooks for RHEL 7.2
# function not indented so ExpectedOF works
networkmanager_72()
{
# https://github.com/cloudera/director-scripts/blob/master/azure-dns-scripts/bootstrap_dns_nm.sh
# RHEL 7.2 uses NetworkManager. Add a script to be automatically invoked when interface comes up.
cat > /etc/NetworkManager/dispatcher.d/12-register-dns <<"EOF"
#!/bin/bash
# NetworkManager Dispatch script
# Deployed by Cloudera Director Bootstrap
#
# Expected arguments:
#    $1 - interface
#    $2 - action
#
# See for info: http://linux.die.net/man/8/networkmanager
# Register A and PTR records when interface comes up
# only execute on the primary nic
if [[ "$1" != "eth0" || "$2" != "up" ]]
then
    exit 0;
fi
# when we have a new IP, perform nsupdate
new_ip_address="$DHCP4_IP_ADDRESS"
host=$(hostname -s)
domain=$(hostname | cut -d'.' -f2- -s)
domain=${domain:='cdh-cluster.internal'} # REPLACE_ME If no hostname is provided, use cdh-cluster.internal
IFS='.' read -ra ipparts <<< "$new_ip_address"
ptrrec="$(printf %s "$new_ip_address." | tac -s.)in-addr.arpa"
nsupdatecmds=$(mktemp -t nsupdate.XXXXXXXXXX)
resolvconfupdate=$(mktemp -t resolvconfupdate.XXXXXXXXXX)
echo updating resolv.conf
grep -iv "search" /etc/resolv.conf > "$resolvconfupdate"
echo "search reddog.microsoft.com" >> "$resolvconfupdate"
echo "search $domain" >> "$resolvconfupdate"
cat "$resolvconfupdate" > /etc/resolv.conf
echo "Attempting to register $host.$domain and $ptrrec"
{
    echo "update delete $host.$domain a"
    echo "update add $host.$domain 600 a $new_ip_address"
    echo "send"
    echo "update delete $ptrrec ptr"
    echo "update add $ptrrec 600 ptr $host.$domain"
    echo "send"
} > "$nsupdatecmds"
nsupdate -g "$nsupdatecmds"
exit 0;
EOF
chmod 755 /etc/NetworkManager/dispatcher.d/12-register-dns
kinit ${DNS_JOIN_USER} <<EOF
${DNS_JOIN_PASS}
EOF
systemctl restart NetworkManager
systemctl restart network
}


rhel_7x()
{
    echo "RHEL 7.x"

    KRB5_CONF=$(mktemp -t krb5_conf.XXXXXXXXXX)
    NTP_CONF=$(mktemp -t ntp_conf.XXXXXXXXXX)
    DIRECTOR_REPO=$(mktemp -t director_repo.XXXXXXXXXX)
    SSSD_CONF=$(mktemp -t sssd_conf.XXXXXXXXXX)
    SSHD_CONF=$(mktemp -t sshd_conf.XXXXXXXXXX)

    ###  Ensure the Node and YUM are up to date.  ###
    yum clean all
    yum makecache fast
    yum -y update
    yum -y install bind-utils wget telnet redhat-lsb-core nscd rng-tools ntp

    ###  Set SELinux to permissive  ###
    sed -i.bak "s/^SELINUX=.*$/SELINUX=disabled/" /etc/selinux/config
    setenforce 0

    ###  Disable tuned so it does not overwrite sysctl.conf  ###
    service tuned stop
    systemctl disable tuned

    ###  Disable chrony so it does not conflict with ntpd installed by Director  ###
    systemctl stop chronyd
    systemctl disable chronyd

    ###  Update config to disable IPv6 and disable  ###
    echo "# Disable IPv6" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

    # swappniess is set by Director in /etc/sysctl.conf
    # Poke sysctl to have it pickup the config change.
    sysctl -p

    ### Enable and start rngd  ###
    echo 'EXTRAOPTIONS="-r /dev/urandom"' > /etc/sysconfig/rngd
    chkconfig rngd on
    service rngd start

    ###  Turn off iptables  ###
    systemctl stop firewalld
    systemctl disable firewalld

    ###  Turn on NTP with internal NTP Server  ###
    sed -e 's/server 0.rhel.pool.ntp.org iburst/#server 0.rhel.pool.ntp.org iburst/' \
     -e 's/server 1.rhel.pool.ntp.org iburst/#server 1.rhel.pool.ntp.org iburst/' \
     -e 's/server 2.rhel.pool.ntp.org iburst/#server 2.rhel.pool.ntp.org iburst/' \
     -e "s/server 3.rhel.pool.ntp.org iburst/#server 3.rhel.pool.ntp.org iburst\n# NTP Server defined manually.\nserver ${DOMAIN_CONTROLLER} prefer/" \
     /etc/ntp.conf > ${NTP_CONF}

    cat ${NTP_CONF} > /etc/ntp.conf
    systemctl restart ntpd
    ntpdate -u ${DOMAIN_CONTROLLER}

    ###  Update Timezone  ###
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/US/Central /etc/localtime

    ###  Download and Install the MySQL Java Connector  ###
    echo "Installing dummy mysql-connector-java"
    yum -y install mysql-connector-java


    echo "Installing the real mysql-connector-java"
    wget "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz" -O /tmp/mysql-connector-java-5.1.40.tar.gz
    tar zxvf /tmp/mysql-connector-java-5.1.40.tar.gz -C /tmp/
    mkdir -p /usr/share/java/
    cp /tmp/mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar /usr/share/java/
    rm /usr/share/java/mysql-connector-java.jar
    ln -s /usr/share/java/mysql-connector-java-5.1.40-bin.jar /usr/share/java/mysql-connector-java.jar


    ###  Install Packages needed for SSSD, DNS, LDAP, and Kerberos  ###
    yum -y install realmd sssd sssd-ad samba-common adcli sssd-libwbclient openldap-devel openldap-clients pam_krb5 samba-common-tools krb5-workstation krb5-libs oddjob-mkhomedir openssl-perl

    ###  Update resolv.conf  ###
    echo "search ${DOMAIN}" >> /etc/resolv.conf

    ###  Change /etc/krb5.conf ###
    echo "[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 default_realm = ${DOMAIN^^}
 default_ccache_name = FILE:/tmp/krb5cc_%{uid}
 udp_preference_limit = 1

[realms]
 ${DOMAIN^^} = {
  kdc = ${DOMAIN_CONTROLLER}
  admin_server = ${DOMAIN_CONTROLLER}
 }

[domain_realm]
 .${DOMAIN} = ${DOMAIN^^}
 ${DOMAIN} = ${DOMAIN^^}
" > "${KRB5_CONF}"

    cat "${KRB5_CONF}" > /etc/krb5.conf
    hostname $(hostname -s).${DOMAIN}
    ###  Join the computer to the domain.  ###
    realm discover ${DOMAIN^^}
    realm join ${DOMAIN^^} -U "${AD_JOIN_USER}" --verbose --computer-ou="${COMPUTER_OU}" <<EOF
${AD_JOIN_PASS}
EOF

    ###  Configure SSSD and SSH configuration.  ###
    sed -e 's/use_fully_qualified_names = True/use_fully_qualified_names = False/' \
     -e 's|fallback_homedir = /home/%u@%d|fallback_homedir = /home/%u|' \
     -e 's|ldap_id_mapping = True|ldap_id_mapping = False|' \
     -e 's|services = nss, pam|services = nss, pam\n\n[nss]\noverride_homedir = /home/%u\ndefault_shell = /bin/bash|' \
     /etc/sssd/sssd.conf > ${SSSD_CONF}

    cat ${SSSD_CONF} > /etc/sssd/sssd.conf
    rm -f /var/lib/sss/db/*
    rm -f /var/lib/sss/mc/*
    systemctl restart sssd

    sed -e 's/PasswordAuthentication no/PasswordAuthentication yes/' \
     -e 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' \
     /etc/ssh/sshd_config > ${SSHD_CONF}

    cat ${SSHD_CONF} > /etc/ssh/sshd_config
    systemctl restart sshd

    # execute the CentOS 7.2 / RHEL 7.2 network manager setup
    networkmanager_72

    ###  Enable and start nscd  ###
    chkconfig nscd on
    service nscd start


echo "Installing Java 8... "

yum remove --assumeyes *openjdk*

###  Install Java 8  ###
rpm -ivh "http://archive.cloudera.com/director/redhat/7/x86_64/director/2.4.0/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update121-1.x86_64.rpm"

LINKDIR=/usr/bin
JHOME=/usr/java/jdk1.8.0_121-cloudera
JREDIR=$JHOME/jre/bin
JDKDIR=$JHOME/bin
 
echo "Setting up java alternatives " 
alternatives --install $LINKDIR/java java $JREDIR/java 20000  \
  --slave $LINKDIR/keytool     keytool     $JREDIR/keytool         \
  --slave $LINKDIR/orbd        orbd        $JREDIR/orbd            \
  --slave $LINKDIR/pack200     pack200     $JREDIR/pack200         \
  --slave $LINKDIR/rmid        rmid        $JREDIR/rmid            \
  --slave $LINKDIR/rmiregistry rmiregistry $JREDIR/rmiregistry     \
  --slave $LINKDIR/servertool  servertool  $JREDIR/servertool      \
  --slave $LINKDIR/tnameserv   tnameserv   $JREDIR/tnameserv       \
  --slave $LINKDIR/unpack200   unpack200   $JREDIR/unpack200       \
  --slave $LINKDIR/jcontrol    jcontrol    $JREDIR/jcontrol        \
  --slave $LINKDIR/javaws      javaws      $JREDIR/javaws
 
alternatives --install $LINKDIR/javac javac $JDKDIR/javac 20000  \
  --slave $LINKDIR/appletviewer appletviewer $JDKDIR/appletviewer     \
  --slave $LINKDIR/apt          apt          $JDKDIR/apt              \
  --slave $LINKDIR/extcheck     extcheck     $JDKDIR/extcheck         \
  --slave $LINKDIR/idlj         idlj         $JDKDIR/idlj             \
  --slave $LINKDIR/jar          jar          $JDKDIR/jar              \
  --slave $LINKDIR/jarsigner    jarsigner    $JDKDIR/jarsigner        \
  --slave $LINKDIR/javadoc      javadoc      $JDKDIR/javadoc          \
  --slave $LINKDIR/javah        javah        $JDKDIR/javah            \
  --slave $LINKDIR/javap        javap        $JDKDIR/javap            \
  --slave $LINKDIR/jcmd         jcmd         $JDKDIR/jcmd             \
  --slave $LINKDIR/jconsole     jconsole     $JDKDIR/jconsole         \
  --slave $LINKDIR/jdb          jdb          $JDKDIR/jdb              \
  --slave $LINKDIR/jhat         jhat         $JDKDIR/jhat             \
  --slave $LINKDIR/jinfo        jinfo        $JDKDIR/jinfo            \
  --slave $LINKDIR/jmap         jmap         $JDKDIR/jmap             \
  --slave $LINKDIR/jps          jps          $JDKDIR/jps              \
  --slave $LINKDIR/jrunscript   jrunscript   $JDKDIR/jrunscript       \
  --slave $LINKDIR/jsadebugd    jsadebugd    $JDKDIR/jsadebugd        \
  --slave $LINKDIR/jstack       jstack       $JDKDIR/jstack           \
  --slave $LINKDIR/jstat        jstat        $JDKDIR/jstat            \
  --slave $LINKDIR/jstatd       jstatd       $JDKDIR/jstatd           \
  --slave $LINKDIR/native2ascii native2ascii $JDKDIR/native2ascii     \
  --slave $LINKDIR/policytool   policytool   $JDKDIR/policytool       \
  --slave $LINKDIR/rmic         rmic         $JDKDIR/rmic             \
  --slave $LINKDIR/schemagen    schemagen    $JDKDIR/schemagen        \
  --slave $LINKDIR/serialver    serialver    $JDKDIR/serialver        \
  --slave $LINKDIR/wsgen        wsgen        $JDKDIR/wsgen            \
  --slave $LINKDIR/wsimport     wsimport     $JDKDIR/wsimport         \
  --slave $LINKDIR/xjc          xjc          $JDKDIR/xjc


alternatives --set java $JREDIR/java
alternatives --set javac $JDKDIR/javac




echo "Installing Java 8... Done"
java -version

echo "Installing Java 8 JCE... "
###  Install Java Unlimited Strength Encryption Policy Files for Java 8  ###
wget -O /tmp/jce_policy-8.zip --no-cookies --no-check-certificate \
      --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
      "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
unzip -o /tmp/jce_policy-8.zip -d /tmp
rm -f ${JHOME}/jre/lib/security/local_policy.jar
rm -f ${JHOME}/jre/lib/security/US_export_policy.jar
mv /tmp/UnlimitedJCEPolicyJDK8/local_policy.jar ${JHOME}/jre/lib/security/local_policy.jar
mv /tmp/UnlimitedJCEPolicyJDK8/US_export_policy.jar ${JHOME}/jre/lib/security/US_export_policy.jar
echo "Installing Java 8 JCE... Done"

}

#
# Main workflow
#

# ensure user is root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# find the OS and release
os=""
release=""

# if it's there, use lsb_release
rpm -q redhat-lsb
if [ $? -eq 0 ]; then
    os=$(lsb_release -si)
    release=$(lsb_release -sr)

# if lsb_release isn't installed, use /etc/redhat-release
else
    grep "Red Hat Enterprise Linux Server release 7" /etc/redhat-release
    if [ $? -eq 0 ]; then
        os="RedHatEnterpriseServer"
        release="7.x"
    fi
fi


# debug
echo $os
echo $release

not_supported_msg="OS $os $release is not supported."

# select the OS and run the appropriate setup script
if [ "$os" = "RedHatEnterpriseServer" ]; then
    if [ "$release" = "7.x" ]; then
        rhel_7x
    else
        echo not_supported_msg
        exit 1
    fi
else
    echo not_supported_msg
    exit 1
fi