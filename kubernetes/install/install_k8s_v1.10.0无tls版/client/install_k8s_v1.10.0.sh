#!/bin/bash
sudo mkdir -p /etc/kubernetes
sudo chmod u+x kube*

sudo yum install -y wget
sudo wget https://dl.k8s.io/v1.10.0/kubernetes-node-linux-amd64.tar.gz
sudo tar xvf kubernetes-node-linux-amd64.tar.gz

sudo setenforce 0

sudo alias cp=cp
sudo cp -f ./kubernetes/node/bin/kube* /usr/local/bin

sudo mkdir -p /var/lib/kubelet
sudo cp -f ./kubelet /etc/kubernetes/kubelet
sudo cp -f ./kubelet.yaml /etc/kubernetes/kubelet.yaml
sudo cp -f ./proxy /etc/kubernetes/proxy

sudo cp -f ./kubelet.service /usr/lib/systemd/system/kubelet.service
sudo cp  -f ./kube-proxy.service /usr/lib/systemd/system/kube-proxy.service

sudo chmod 644 /etc/kubernetes/kubelet
sudo chmod 644 /etc/kubernetes/kubelet.yaml
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
