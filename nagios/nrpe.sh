yum install epel-release
yum install nrpe nagios-plugins-all
systemctl start nrpe.service
systemctl enable nrpe.service
