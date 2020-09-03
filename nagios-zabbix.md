# Scripts to install nagios/zabbix server/agent
## Install nagios server
```
wget -O - https://raw.githubusercontent.com/leehuynhfvn/my-public-note/master/nagios/nagios-server.sh | bash
```
## Install nrpe 
```
wget -O -  https://raw.githubusercontent.com/leehuynhfvn/my-public-note/master/nagios/nrpe.sh | bash /dev/stdin [ip nagios server]
```
## Install zabbix server
```
wget -O - https://raw.githubusercontent.com/leehuynhfvn/my-public-note/master/zabbix/zabbix-server.sh | bash
```
### Install zabbix agent
wget -O - https://raw.githubusercontent.com/leehuynhfvn/my-public-note/master/zabbix/zabbix-agent.sh | bash /dev/stdin [ip zabbix server]
