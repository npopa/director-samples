#!/bin/bash

##### Install mariadb server

if [[ -f /tmp/params.sh ]]; then 
	source /tmp/params.sh
fi

if [[ -z ${MYSQL_ADMIN} || -z ${MYSQL_ADMIN_PASS} ]]; then
	echo ' ${MYSQL_ADMIN}, ${MYSQL_ADMIN_PASS} must be defined'
	exit 1
fi


yum install -y mariadb-server

cat <<EOF >/etc/my.cnf
[mysqld]
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
# symbolic-links = 0

key_buffer = 16M
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1

max_connections = 550
#expire_logs_days = 10
#max_binlog_size = 100M

#log_bin should be on a disk with enough free space. Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your system
#and chown the specified folder to the mysql user.
log_bin=/var/lib/mysql/mysql_binary_log

binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 512M
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid


EOF
systemctl start mariadb
systemctl enable mariadb

/usr/bin/mysqladmin -u ${MYSQL_ADMIN} password ${MYSQL_ADMIN_PASS}

mysql -u ${MYSQL_ADMIN} --password=${MYSQL_ADMIN_PASS} <<-ESQL
use mysql;
delete from user where user='';
delete from user where user='${MYSQL_ADMIN}' and host like '%.local';
delete from user where user='${MYSQL_ADMIN}' and host like '%.lan';
delete from user where user='${MYSQL_ADMIN}' and host like '%.internal';
delete from user where user='${MYSQL_ADMIN}' and host like '%.com';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';
UPDATE user SET Grant_priv = 'Y' WHERE User = '${MYSQL_ADMIN}';
flush privileges;
ESQL



