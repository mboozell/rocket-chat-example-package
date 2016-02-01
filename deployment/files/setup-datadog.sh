#!/bin/bash

ip=`hostname -I | xargs`
hostname=`hostname`

# install datadog
DD_API_KEY=37b7f7b2aa9cafbef4a015e77b2ac18c bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"

# only need to add user on master node
if [ hostname = "sanglucci-primary" ]; then
mongo <<EOF

use admin
db.createUser({"user":"datadog", "pwd": "HJYSjOGZIh6bsvBWcFuJNbml", "roles" : [ 'read', 'clusterMonitor']})

EOF
end

# add monitoring script for mongo

cat <<EOF > /etc/dd-agent/conf.d/mongo.yaml
init_config:

instances:
      -   server: mongodb://datadog:HJYSjOGZIh6bsvBWcFuJNbml@$ip:27017
EOF

# add monitoring script for node

#cat <<EOF > /etc/dd-agent/conf.d/process.yaml

# init_config:
#  pid_cache_duration: 1

# instances:

#  - name: rocketchat-node
#    search_string: ['node']
#    exact_match: False
#    thresholds:
#	  warning: [1, 2]
#      critical: [1, 1]
#EOF

# add nginx status check

cat <<EOF > /etc/nginx/sites-available/localhost_status

server {
  listen 80;
  server_name localhost;

  access_log off;
  allow 127.0.0.1;
  deny all;

  location /nginx_status {
    stub_status on;
  }
}

EOF

ln -s /etc/nginx/sites-available/localhost_status /etc/nginx/sites-enabled/localhost_status
service nginx restart

cat <<EOF > /etc/dd-agent/conf.d/nginx.yaml

init_config:

instances:
  - nginx_status_url: http://localhost/nginx_status/

EOF

# HTTP check

cat <<EOF > /etc/dd-agent/conf.d/http_check.yaml
init_config:

instances:
  - name: rocketchat-node
    url: http://$ip:8080
    timeout: 1
    http_response_status_code: 200
    headers:
        Host: live.wallstjesus.com
    skip_event: true

  - name: rocketchat-https-nginx
    url: https://$ip
    timeout: 1
    http_response_status_code: 200
    headers:
        Host: live.wallstjesus.com
    skip_event: true
    disable_ssl_validation: false
    check_certificate_expiration: true
    days_warning: 14
    days_critical: 7
	
EOF

/etc/init.d/datadog-agent restart

dd-agent info
