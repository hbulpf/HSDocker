#!/bin/bash
mkdir -p /etc/kubernetes

sudo setenforce 0

yum install -y wget
wget https://dl.k8s.io/v1.10.0/kubernetes-node-linux-amd64.tar.gz
tar -xzvf kubernetes-node-linux-amd64.tar.gz

cd kubernetes
tar -xzvf  kubernetes-src.tar.gz
cp -r ./node/bin/{kube-proxy,kubelet} /usr/local/bin/


cd ..

mkdir -p /var/lib/kubelet
cp -f ./kubelet /etc/kubernetes/kubelet
cp -f ./proxy /etc/kubernetes/proxy

cp -f ./kubelet.service /usr/lib/systemd/system/kubelet.service
cp  -f ./kube-proxy.service /usr/lib/systemd/system/kube-proxy.service

sudo chmod 644 /etc/kubernetes/kubelet
sudo chmod 644 /etc/kubernetes/proxy

systemctl daemon-reload
systemctl enable kubelet.service 
systemctl start kubelet.service

systemctl enable kube-proxy.service
systemctl start kube-proxy.service

echo "                               kubernets service status"
echo "------------------------------------------------------------------------------------------------"
systemctl status kube*
echo "------------------------------------------------------------------------------------------------"
