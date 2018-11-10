
yum remove -y flannel
yum install -y flannel

sudo cp -f ./etcd.service /usr/lib/systemd/system/etcd.service

