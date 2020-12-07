#!/bin/bash
# Install zabbix to CentOS

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
# Vars
# ---------------------------------------------------\
TIMEZONE_REGION="Asia"
TIMEZONE_CITY="Ho_Chi_Minh"
SERVER_IP=$(hostname -I | cut -d' ' -f1)
SERVER_NAME=$(hostname)
DB_ZAB_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
DB_ROOT_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
# Install base software && Add new repos
yum install epel-release yum-utils net-tools -y
# Zabbix repo
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
yum-config-manager --enable rhel-7-server-optional-rpms
# Remi repo (for new php releases)
#rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
#yum-config-manager --enable remi-php72
# Install and configure Mariadb
# ---------------------------------------------------\
yum install mariadb mariadb-server -y

# my.cnf additional settings for InnoDB log rotate
touch /etc/my.cnf.d/innolog.conf

cat >> /etc/my.cnf.d/innolog.conf <<_EOF_
# Innodb
innodb_file_per_table
#
innodb_log_group_home_dir = /var/lib/mysql/
innodb_buffer_pool_size = 4G
innodb_additional_mem_pool_size = 16M
#
innodb_log_files_in_group = 2
innodb_log_file_size=512M
innodb_log_buffer_size = 8M
innodb_lock_wait_timeout = 120
#
innodb_thread_concurrency = 4
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
#
#wsrep_provider_options="gcache.size=128M"
_EOF_
# Enable and start MariaDB
systemctl enable mariadb && systemctl start mariadb
# mysql_secure_installation analog
mysql --user=root <<_EOF_
  UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT_PASS}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
# Create zabbix databse and user
cat <<EOF | mysql -uroot -p$DB_ROOT_PASS
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by '${DB_ZAB_PASS}';
flush privileges;
EOF

# Install Zabbix-Server, Zabbix-agent, httpd
# ---------------------------------------------------\
yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent httpd -y

# Import zabbix default db to zabbix database
ZABB_MYSQL_VERSION=$(zabbix_server_mysql --version | head -1 | awk '{print $3}')

zcat /usr/share/doc/zabbix-server-mysql-$ZABB_MYSQL_VERSION/create.sql.gz | mysql -uroot -p$DB_ROOT_PASS zabbix

# Configure zabbix
sed -i 's/# DBHost=.*/DBHost=localhost/' /etc/zabbix/zabbix_server.conf
sed -i 's/# DBName=.*/DBName=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i 's/# DBUser=.*/DBUser=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i "s/# DBPassword=.*/DBPassword="$DB_ZAB_PASS"/" /etc/zabbix/zabbix_server.conf

# Configure php.ini
sed -i 's/^\(max_execution_time\).*/\1 = 300/' /etc/php.ini
sed -i 's/^\(memory_limit\).*/\1 = 128M/' /etc/php.ini
sed -i 's/^\(post_max_size\).*/\1 = 16M/' /etc/php.ini
sed -i 's/^\(upload_max_filesize\).*/\1 = 2M/' /etc/php.ini
sed -i 's/^\(max_input_time\).*/\1 = 300/' /etc/php.ini
sed -i "s/^\;date.timezone.*/date.timezone = \'"$TIMEZONE_REGION"\/"$TIMEZONE_CITY"\'/" /etc/php.ini

# Configure local zabbix agent
sed -i "s/^\(Server=\).*/\1"127.0.0.1,localhost,$SERVER_IP"/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^\(ServerActive\).*/\1="$SERVER_IP"/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^\(Hostname\).*/\1="$SERVER_NAME"/" /etc/zabbix/zabbix_agentd.conf

# Configure firewalld
# ---------------------------------------------------\
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --reload

# Enable and start zabbix, httpd services
systemctl enable zabbix-server && systemctl start zabbix-server
systemctl enable httpd && systemctl start httpd
systemctl enable zabbix-agent && systemctl start zabbix-agent

# Final message
# ---------------------------------------------------\
echo -e "\nNow you can install and configure Zabbix!\n\nLink to Zabbix server - http://$SERVER_IP/zabbix\nDB Password - $DB_ZAB_PASS\nDefault login - Admin\nDefault password - zabbix\n"
echo -e "\nMariaDB root password - $DB_ROOT_PASS\n"
echo -e "Zabbix:\nDBUser: zabbix\nDBPass: $DB_ZAB_PASS\nLink to Zabbix server - http://$SERVER_IP/zabbix\n\nMariaDB\nROOTPass: $DB_ROOT_PASS" > $SCRIPT_PATH/zabbix-creds.txt
echo -e "\nCredential data saved to - $SCRIPT_PATH/zabbix-creds.txt"
