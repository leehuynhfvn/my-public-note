#!/bin/bash
# Install zabbix agent to CentOS

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Additions
# ---------------------------------------------------\
Info() {
	printf "\033[1;32m$@\033[0m\n"
}

Error()
{
	printf "\033[1;31m$@\033[0m\n"
}

isRoot() {
	if [ $(id -u) -ne 0 ]; then
		echo "You must be root user to continue"
		exit 1
	fi
	RID=$(id -u root 2>/dev/null)
	if [ $? -ne 0 ]; then
		echo "User root no found. You should create it to continue"
		exit 1
	fi
	if [ $RID -ne 0 ]; then
		echo "User root UID not equals 0. User root must have UID 0"
		exit 1
	fi
}

isRoot

# Vars
# ---------------------------------------------------\
SERVER_IP=$1
HOST_NAME=$(hostname)
HOST_IP=$(hostname -I | cut -d' ' -f1)

# Secure agent
PSKIdentity=${HOST_NAME%.*.*}
TLSType="psk"
RAND_PREFIX="-$TLSType-prefix-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)"

if [[ -f /etc/zabbix/zabbix_agentd.conf ]]; then
	echo "Zabbix agent already installed!"
	exit 1
fi


if [ -z "$1" ]; then
    echo "\nPlease call '$0 <Zabbix Server IP>' to run this command!\n"
    exit 1
fi


# Installation
# ---------------------------------------------------\

yum install epel-release -y
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm

yum install zabbix-agent -y

# Configure local zabbix agent
sed -i "s/^\(Server=\).*/\1"$SERVER_IP"/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^\(ServerActive\).*/\1="$SERVER_IP"/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^\(Hostname\).*/\1="$HOST_NAME"/" /etc/zabbix/zabbix_agentd.conf


# Configure firewalld
# ---------------------------------------------------\
firewall-cmd --permanent  --add-port=10050/tcp
firewall-cmd --reload

# Enable and start agent
# ---------------------------------------------------\
systemctl enable zabbix-agent && systemctl start zabbix-agent

# Final
# ---------------------------------------------------\
echo -e ""
Info "Done!"
Info "Now, you must add this host to your Zabbix server in the Configuration > Hosts area"
Info "This server ip - $HOST_IP"
Info "This server name - $HOST_NAME"
