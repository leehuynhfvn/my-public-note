#!/bin/bash
# Install Nagios agent on CentOS
# Precheck
if [[ -f /etc/nagios/nrpe.cfg ]]; then
        echo "Nrpe already installed!"
        exit 1
fi


if [ -z "$1" ]; then
    echo "Please call '$0 <Nagios Server IP>' to run this command!"
    exit 1
fi

# Installation
# ---------------------------------------------------\

yum install epel-release
yum install nrpe -y
mkdir -p /usr/lib64/nagios/plugins
wget -P /usr/lib64/nagios/plugins -c https://raw.githubusercontent.com/leehuynhfvn/my-public-note/master/nagios/plugins.tar.gz -O - | tar -xz

# Config nrpe
sed -i "/^allowed_hosts/ s/$/\,$SERVER_IP/" /etc/nagios/nrpe.cfg
sed -i "s/^NRPE_SSL_OPT=\"\"$/NRPE_SSL_OPT=\"-n\"/" /etc/sysconfig/nrpe

# Configure firewalld
# ---------------------------------------------------\
firewall-cmd --permanent  --add-port=5666/tcp
firewall-cmd --reload


# Start service
systemctl start nrpe.service
systemctl enable nrpe.service
