#!/bin/bash

. ./config-common.sh



setup_upstart_config Web.Development "https:\/\/chat-dev.sanglucci.com" 8082 "mongodb:\/\/$ip:27017\/SangLucci_Chat-Web_Development?replicaSet=rs0" "mongodb:\/\/$ip:27017\/local"
setup_nginx_config sanglucci.com chat-dev.sanglucci.com 8082

setup_upstart_config Web.QA "https:\/\/chat-qa.sanglucci.com" 8081 "mongodb:\/\/$ip:27017\/SangLucci_Chat-Web_QA?replicaSet=rs0" "mongodb:\/\/$ip:27017\/local"
setup_nginx_config sanglucci.com chat-qa.sanglucci.com 8081

