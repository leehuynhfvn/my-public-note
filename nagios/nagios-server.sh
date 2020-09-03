yum install nagios.x86_64 -y
mkdir -p /lib64/nagios/plugins
wget -P /lib64/nagios/plugins/ -c  https://github.com/leehuynhfvn/my-public-note/blob/master/nagios/plugins.tar.gz -O - | tar -xz
wget -P /usr/local/bin/ -c https://raw.githubusercontent.com/leehuynhfvn/my-public-note/master/nagios/sendEmail && chmod +x /usr/local/bin/sendEmail
wget -P /usr/local/bin -c https://github.com/leehuynhfvn/my-public-note/blob/master/nagios/nagios2chatwork.sh && chmod +x /usr/local/bin/nagios2chatwork.sh
wget -c https://raw.githubusercontent.com/leehuynhfvn/my-public-note/master/nagios/commands.cfg -O - | cat >> /etc/nagios/objects/commands.cfg
sed '26,38 {s/^/#/}' -i /etc/nagios/objects/commands.cfg
pass=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
echo "$pass" | htpasswd -c -i /etc/nagios/passwd nagiosadmin
echo nagios:$pass > ~nagios/nagiosadmin
nagios -v /etc/nagios/nagios.cfg
if [ $? -eq 0 ]
then 
systemctl --now enable nagios
systemctl --now enable httpd 
fi
echo "
###################################################
login to http://$(hostname -I|cut -d' ' -f1)/nagios
user: nagiosadmin
password: $pass
For setting to notify via email and chatwork
setting smtp to send email notification at /etc/nagios/objects/commands.cfg 
setting token for chatwork notification at /usr/local/bin/nagios2chatwork.sh
Open nagios2chatwork.sh in an editor, Put the Chatwork API token in CW_TOKEN and the room_id of the chat you want to notify in CW_ROOMID. 
###################################################
"
