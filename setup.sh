#!/bin/bash

# Run this scrip with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if id admin &>/dev/null; then
    echo 'admin user already exists'
else
    echo 'creating admin user'

    echo '%wheel        ALL=(ALL)       ALL' >> /etc/sudoers
    useradd admin
    usermod –aG wheel UserName
fi

echo "adding elastic repos"
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cp ./elasticsearch.repo /etc/yum.repos.d/
cp ./kibana.repo /etc/yum.repos.d/

echo "installing elastic components"
yum install -y --enablerepo=elasticsearch elasticsearch-7.8.1
yum install -y kibana-7.8.1
yum install -y filebeat-7.8.1
yum install -y auditbeat-7.8.1

# Todo, copy the configs
cp ./configs/elasticsearch.yml /etc/elasticsearch/config
cp ./configs/kibana.yml /etc/kibana/config/
cp ./configs/filebeat/filebeat.yml /etc/filebeat/
cp ./configs/filebeat/modules/* /etc/filebeat/modules.d/

/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service

# Lets add a bootstrap password
echo "lockdown" | elasticsearch-keystore add -x

sudo systemctl start elasticsearch.service

echo "Waiting for Elasticsearch to start"
until $(curl -uelastic:"lockdown" --output /dev/null --silent --head --fail http://localhost:9200); do
    printf '.'
    sleep 5
done

echo "Setting passwords"
curl -uelastic:"top-secret" -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana_system/_password 81' -d '{ "password”:”lockdown” }'
curl -X POST "localhost:9200/_security/user/beats?pretty" -H 'Content-Type: application/json' -d'
{
  "password" : "lockdown",
  "roles" : [ "superuser"],
  "full_name" : "Beats",
  "email" : "beats@example.com",
}
'
curl -X POST "localhost:9200/_security/user/user1?pretty" -H 'Content-Type: application/json' -d'
{
  "password" : "lockdown",
  "roles" : [ "superuser"],
  "full_name" : "Beats",
  "email" : "beats@example.com",
}
'


