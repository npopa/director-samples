#READ_ME.txt


Director 

Deploy a new VM on azure for director with RHEL7.2
Run:
 - sudo ./bootstrap_RHEL7x.sh
 - sudo ./install_mysql.sh
 - sudo ./install_director.sh
 - sudo ./install_certs.sh


CDH 
Run:
. ./azure_cdh.sh
cloudera-director bootstrap-remote /home/cloudera/azure_cdh-param.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189


. ./azure_kts.sh
cloudera-director bootstrap-remote /home/cloudera/azure_kts-param.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=${DIRECTOR_IP}:7189

