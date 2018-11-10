#!/bin/bash
firewall-cmd --zone=public --add-port=2380/tcp --permanent
firewall-cmd --zone=public --add-port=2379/tcp --permanent
firewall-cmd --reload

yum install -y epel-release 
yum clean all 
yum list

yum remove -y etcd 

wget https://github.com/coreos/etcd/releases/download/v3.1.5/etcd-v3.1.5-linux-amd64.tar.gz
tar -xvf etcd-v3.3.9-linux-amd64.tar.gz
mv etcd-v3.3.9-linux-amd64/etcd* /usr/local/bin

sudo cp -f ./etcd.service /usr/lib/systemd/system/etcd.service

mkdir -p /var/lib/etcd

cat > /etc/etcd/etcd.conf << EOF
# [member]
ETCD_NAME=infra1
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://master:2380"
ETCD_LISTEN_CLIENT_URLS="https://master:2379"

#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://master:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://master:2379"
EOF

systemctl daemon-reload
systemctl enable etcd.service
systemctl start etcd.service

echo "                                      etcd service status"
echo "------------------------------------------------------------------------------------------------"
systemctl status etcd*
echo "------------------------------------------------------------------------------------------------"

echo "                                      etcd version"
echo "------------------------------------------------------------------------------------------------"
etcd -version
echo "------------------------------------------------------------------------------------------------"

echo "                                      etcdctl cluster-health"
echo "------------------------------------------------------------------------------------------------"
etcdctl cluster-health
echo "------------------------------------------------------------------------------------------------"
