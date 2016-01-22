#!/bin/bash

. ./config-common.sh

echo "10.0.0.4 sanglucci-primary" >> /etc/hosts
echo "10.0.0.5 sanglucci-secondary" >> /etc/hosts
echo "10.0.0.6 sanglucci-arb" >> /etc/hosts

ip=`hostname -I | xargs`
hostname=`hostname`

setup_upstart_config Web.Development "https:\/\/live.wallstjesus.com" 8080 "mongodb:\/\/sanglucci-primary:27017,sanglucci-secondary:27017,sanglucci-arb:27017\/SangLucci_Chat-Web_Production?replicaSet=rs0\&readPreference=nearest\&w=majority" "mongodb:\/\/sanglucci-primary:27017,sanglucci-secondary:27017,sanglucci-arb:27017\/local"
setup_nginx_config wallstjesus.com live.wallstjesus.com 8080

# add mongo backup job

cp backup-mongo.sh /storage/apps

if [ hostname = "sanglucci-primary" ]; then
	echo "0 */2 	* * * root /storage/apps/backup-mongo.sh" >> /etc/crontab
elif [ hostname = "sanglucci-secondary" ] then
	echo "0 1-23/2 	* * * root /storage/apps/backup-mongo.sh" >> /etc/crontab
fi