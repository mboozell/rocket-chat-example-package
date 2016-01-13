#!/bin/bash

function setup_upstart_config() {
	# $1 = Environment Name
	# $2 = Root URL
	# $3 = Port
	# $4 = Mongo URL
	# $5 = Mongo Oplog URL
	
	conf="/etc/init/SangLucci.Chat-$1.conf"
	
	cp upstart.template.conf $conf
	
	sed -i "s/__ENVIRONMENT__/$1/" $conf
	sed -i "s/__ROOT_URL__/$2/" $conf
	sed -i "s/__PORT__/$3/" $conf
	sed -i "s/__MONGO_URL__/$4/" $conf
	sed -i "s/__MONGO_OPLOG_URL__/$5/" $conf
	
cat <<EOF > /etc/logrotate.d/SangLucci.Chat-$1
/var/log/apps/SangLucci.Chat/$1/*.log {
  weekly
  rotate 8
  compress
  missingok
  notifempty
  create 0664 sanglucci root
  su sanglucci
}
EOF
}

function setup_nginx_config() {
	# $1 = DOMAIN
	# $2 = HOST
	# $3 = PORT
	
	conf="/etc/nginx/sites-available/$2"
	ip=`hostname -I | xargs`
	
	cp nginx.template.conf $conf
	
	sed -i "s/__DOMAIN__/$1/" $conf
	sed -i "s/__HOST__/$2/" $conf
	sed -i "s/__PORT__/$3/" $conf
	sed -i "s/__IP__/$ip/" $conf
	
	ln -sf $conf "/etc/nginx/sites-enabled/$2"
}

# disable provisioning
sed -i -e "s/\(Provisioning.Enabled *= *\).*/\1n/" /etc/waagent.conf

# add hostname to loopback
echo "127.0.0.1 `hostname`" >> /etc/hosts

# setup RAID
if [ -e /dev/sdc ] && [ -e /dev/sdd ]; then

	fdisk /dev/sdc <<EOF
	n
	p
	1


	t
	fd
	w
	EOF

	fdisk /dev/sdd <<EOF
	n
	p
	1


	t
	fd
	w
	EOF

	mdadm --create /dev/md127 --level=0 --chunk=64 --raid-devices=2 /dev/sdc1 /dev/sdd1
	mkfs -t xfs /dev/md127
	mkdir /storage
	
	uuid=`blkid | sed -n '/md127/s/.*UUID=\"\([^\"]*\)\".*/\1/p'`
	echo "UUID=$uuid /storage xfs defaults,noatime,nobootwait 0 2" >> /etc/fstab

	# Set readahead to 32 (16 KB)
	blockdev --setra 32 /dev/md127
	
	# configure mongo storage
	mkdir /storage/db
	chown mongodb.mongodb /storage/db/
fi

# setup mongo config
dbPath="/var/lib/mongodb"
if [ -d /storage/db ]; then
	dbPath="/storage/db"
fi

journalEnabled="true"
mmapConfig=""

# disable journal and small files for arb
if [ `hostname` = "sanglucci-arb" ]; then
	journalEnabled="false"
	mmapConfig="smallFiles: false"
fi

bindIp=`hostname -I`

# cat them to config
cat <<EOF > /etc/mongod.conf

storage:
  dbPath: $dbPath
  journal:
    enabled: $journalEnabled

  mmapv1:
    $mmapConfig

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 127.0.0.1,$bindIp

replication:
  replSetName: rs0
  oplogSizeMB: 2048

EOF

# Set up application

mkdir /storage/apps
chown sanglucci.sanglucci /storage/apps
ln -s /storage/apps /var/apps

mkdir /var/log/apps
chown sanglucci.sanglucci /var/log/apps

# setup nginx

sed -i s/#.server_tokens/server_tokens/ /etc/nginx/nginx.conf

cat <<EOF >> /etc/nginx/nginx.conf

http {
        ##
        # SSL Settings
        ##

        ssl_protocols                           TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4";
        ssl_prefer_server_ciphers               on;
        ssl_stapling                            on;
        ssl_stapling_verify                     on;
        ssl_dhparam                             /etc/ssl/certs/dhparam.pem;
        ssl_session_cache                       shared:SSL:10m;
        ssl_session_timeout                     10m;

        add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
}
EOF

