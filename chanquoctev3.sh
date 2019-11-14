#!/bin/bash
case $1 in 
	on)
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1
iptables -F chain-279974929973dac0e1a04b
iptables -N chain-279974929973dac0e1a04b 
iptables -I INPUT -j chain-279974929973dac0e1a04b
iptables -I OUTPUT -j chain-279974929973dac0e1a04b
iptables -I chain-279974929973dac0e1a04b -s 127.0.0.0/8 -j RETURN
iptables -I chain-279974929973dac0e1a04b -s 10.0.0.0/8 -j RETURN
iptables -I chain-279974929973dac0e1a04b -s 172.16.0.0/12 -j RETURN
iptables -I chain-279974929973dac0e1a04b -s 192.168.0.0/16 -j RETURN
#######Download #########
curl http://www.ipdeny.com/ipblocks/data/countries/vn.zone -o vn.zone
curl https://asn.ipinfo.app/api/text/list/AS32934 | grep -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | tee facebook
curl https://asn.ipinfo.app/api/text/list/AS15169 | grep -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | tee google
for i in $(cat vn.zone); do
	iptables -I chain-279974929973dac0e1a04b -s $i -j RETURN
	iptables -I chain-279974929973dac0e1a04b -d $i -j RETURN
	done
for i in $(cat facebook); do
	iptables -I chain-279974929973dac0e1a04b -s $i -j RETURN
	iptables -I chain-279974929973dac0e1a04b -d $i -j RETURN
	done
for i in $(cat google); do
	iptables -I chain-279974929973dac0e1a04b -s $i -j RETURN
	iptables -I chain-279974929973dac0e1a04b -d $i -j RETURN
	done		
iptables -A chain-279974929973dac0e1a04b -j DROP
;;
	off)
iptables -D INPUT -j chain-279974929973dac0e1a04b
iptables --flush chain-279974929973dac0e1a04b
iptables -X chain-279974929973dac0e1a04b
;;   
	*)
echo Tool block all international traffic. Only alow FACEBOOK, GOOGLE and VIETNAM 	
echo Using:
echo \"bash chanquocte.sh on\" to turn only
echo \"bash chanquocte.sh off\" to turn off
esac
