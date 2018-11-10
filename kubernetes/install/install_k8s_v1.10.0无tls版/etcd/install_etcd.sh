#!/bin/bash
systemctl disable firewalld
systemctl stop firewalld

sudo yum install -y epel-release 
sudo yum clean all 
sudo yum list

sudo yum install -y etcd 

sudo alias cp=cp
sudo chmod u+x etcd*
sudo cp -f ./etcd.service /usr/lib/systemd/system/etcd.service
mkdir -p /var/lib/etcd

systemctl daemon-reload
systemctl enable etcd.service
systemctl start etcd.service

echo "                                      etcd service status"
echo "------------------------------------------------------------------------------------------------"
systemctl status etcd*
echo "------------------------------------------------------------------------------------------------"

echo "                                      etcd version"
echo "------------------------------------------------------------------------------------------------"
etcd -v
echo "------------------------------------------------------------------------------------------------"

echo "                                      etcdctl cluster-health"
echo "------------------------------------------------------------------------------------------------"
etcdctl cluster-health
echo "------------------------------------------------------------------------------------------------"
