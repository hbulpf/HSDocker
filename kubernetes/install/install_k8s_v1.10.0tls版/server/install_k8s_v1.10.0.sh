#!/bin/bash
#!/bin/bash


yum install -y wget


wget https://dl.k8s.io/v1.10.0/kubernetes-server-linux-amd64.tar.gz
tar xvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
tar -xzvf  kubernetes-src.tar.gz
cd ..
cp -r server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl} /usr/local/bin/


cp -f ./apiserver /etc/kubernetes/apiserver
cp -f ./controller-manager /etc/kubernetes/controller-manager
cp -f ./scheduler /etc/kubernetes/scheduler
cp -f ./config /etc/kubernetes/config

cp -f ./kube-apiserver.service /usr/lib/systemd/system/kube-apiserver.service
cp -f ./kube-controller-manager.service /usr/lib/systemd/system/kube-controller-manager.service
cp -f ./kube-scheduler.service /usr/lib/systemd/system/kube-scheduler.service

sudo chmod 644 /etc/kubernetes/apiserver
sudo chmod 644 /etc/kubernetes/controller-manager
sudo chmod 644 /etc/kubernetes/scheduler
sudo chmod 644 /etc/kubernetes/config

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