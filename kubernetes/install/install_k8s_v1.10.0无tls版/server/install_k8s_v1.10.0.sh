#!/bin/bash
sudo mkdir -p /etc/kubernetes
sudo chmod u+x kube*
sudo alias cp=cp

sudo yum -y install wget
wget https://dl.k8s.io/v1.10.0/kubernetes-server-linux-amd64.tar.gz
tar xvf kubernetes-server-linux-amd64.tar.gz

sudo cp -f ./kubernetes/server/bin/kube* /usr/local/bin
sudo cp -f ./apiserver /etc/kubernetes/apiserver
sudo cp -f ./controller-manager /etc/kubernetes/controller-manager
sudo cp -f ./scheduler /etc/kubernetes/scheduler

sudo cp -f ./kube-apiserver.service /usr/lib/systemd/system/kube-apiserver.service
sudo cp  -f ./kube-controller-manager.service /usr/lib/systemd/system/kube-controller-manager.service
sudo cp  -f ./kube-scheduler.service /usr/lib/systemd/system/kube-scheduler.service

sudo chmod 644 /etc/kubernetes/apiserver
sudo chmod 644 /etc/kubernetes/controller-manager
sudo chmod 644 /etc/kubernetes/scheduler
systemctl daemon-reload
systemctl enable kube-apiserver.service
systemctl restart kube-apiserver.service

systemctl enable kube-controller-manager.service
systemctl restart kube-controller-manager.service

systemctl enable kube-scheduler.service
systemctl restart kube-scheduler.service

echo "                               kubernets service status"
echo "------------------------------------------------------------------------------------------------"
systemctl status kube*
echo "------------------------------------------------------------------------------------------------"
echo "                                      kubernets version"
echo "------------------------------------------------------------------------------------------------"
kubectl version
echo "------------------------------------------------------------------------------------------------"