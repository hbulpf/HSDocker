#安装kubernetes v1.10.1无tls版本文档说明
___
##etcd安装
通过yum 源直接安装etcd，注意在下载的时候要更新yum源


```
#centos7 dist
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
#nstall and enable the Extra Packages for Enterprise Linux (EPEL) repository
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y remove etcd
alias cp=cp
chmod u+x etcd*
cp -f ./etcd.service /usr/lib/systemd/system/etcd.service
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
 
```
其中etcd.service如下,如果要配置etcd集群，只需要修改etcd.conf文件即可，此处仅配置当个etcd节点。

```
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/bin/etcd

[Install]
WantedBy=multi-user.target
```

##kubernetes的master结点的安装

在master结点需要安装总共三部分，包括apiserver、kube-controller-manager、kube-scheduler。整个运行脚本如下：

```
#!/bin/bash
mkdir -p /etc/kubernetes
chmod u+x kube*
alias cp=cp

yum -y install wget
wget https://dl.k8s.io/v1.10.0/kubernetes-server-linux-amd64.tar.gz
tar xvf kubernetes-server-linux-amd64.tar.gz

setenforce 0

cp -f ./kubernetes/server/bin/kube* /usr/local/bin
cp -f ./apiserver /etc/kubernetes/apiserver
cp -f ./controller-manager /etc/kubernetes/controller-manager
cp -f ./scheduler /etc/kubernetes/scheduler

cp -f ./kube-apiserver.service /usr/lib/systemd/system/kube-apiserver.service
cp  -f ./kube-controller-manager.service /usr/lib/systemd/system/kube-controller-manager.service
cp  -f ./kube-scheduler.service /usr/lib/systemd/system/kube-scheduler.service

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

```
###kube-apiserver
Kube Controller Manager作为集群内部的管理控制中心,负责集群内的Node、Pod副本、服务端点（Endpoint）、命名空间（Namespace）、服务账号（ServiceAccount）、资源定额（ResourceQuota）的管理，当某个Node意外宕机时，Kube Controller Manager会及时发现并执行自动化修复流程，确保集群始终处于预期的工作状态。

kube-apiserver.service

```
[Unit]
Description=Kube API  Server
After=etcd.service
Wants=etcd.service
 
[Service]
Type=notify
EnvironmentFile=/etc/kubernetes/apiserver
ExecStart=/usr/local/bin/kube-apiserver $KUBE_API_ARGS
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target


```

配置文件apiserver

```
KUBE_API_ARGS="--etcd-servers=http://127.0.0.1:2379 --insecure-bind-address=0.0.0.0 --insecure-port=8080 --service-cluster-ip-range=170.170.0.0/16 --service-node-port-range=1-65535 --admission-control=NamespaceLifecycle,LimitRanger,ResourceQuota --logtostderr=false --log-dir=/home/k8s/log/kubenetes --v=2"
```

###安装kube-controller-manager

Kube Controller Manager作为集群内部的管理控制中心,负责集群内的Node、Pod副本、服务端点（Endpoint）、命名空间（Namespace）、服务账号（ServiceAccount）、资源定额（ResourceQuota）的管理，当某个Node意外宕机时，Kube Controller Manager会及时发现并执行自动化修复流程，确保集群始终处于预期的工作状态。

kube-controller-manager.service

```
[Unit]
Description=Kube Controller Manager
After=kube-apiserver.service
Requires=kube-apiserver.service
 
[Service]
EnvironmentFile=/etc/kubernetes/controller-manager
ExecStart=/usr/local/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target


```

配置文件controller-manager

```
KUBE_CONTROLLER_MANAGER_ARGS="--master=http://127.0.0.1:8080 --logtostderr=false --log-dir=/home/chen/log/kubernetes --v=2"
```

###安装kube-scheduler
Kube Scheduler是负责调度Pod到具体的Node，它通过API Server提供的接口监听Pods，获取待调度pod，然后根据一系列的预选策略和优选策略给各个Node节点打分排序，然后将Pod调度到得分最高的Node节点上。

kube-scheduler 

```
[Unit]
Description=Kube Scheduler
After=kube-apiserver.service
Requires=kube-apiserver.service
 
[Service]
EnvironmentFile=/etc/kubernetes/scheduler
ExecStart=/usr/local/bin/kube-scheduler $KUBE_SCHEDULER_ARGS
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target
```

配置文件scheduler

```
KUBE_SCHEDULER_ARGS="--master=http://127.0.0.1:8080 --logtostderr=false --log-dir=/var/log/kubernetes --v=2"
```


##kubernetes的node结点的安装

在node结点都需要安装总共两部分，kubelet以及kube-proxy，自动化脚本如下

```
#!/bin/bash
mkdir -p /etc/kubernetes
chmod u+x kube*

yum install -y wget
wget https://dl.k8s.io/v1.10.0/kubernetes-node-linux-amd64.tar.gz
tar xvf kubernetes-node-linux-amd64.tar.gz

setenforce 0

alias cp=cp
cp -f ./kubernetes/node/bin/kube* /usr/local/bin

mkdir -p /var/lib/kubelet
cp -f ./kubelet /etc/kubernetes/kubelet
cp -f ./kubelet.yaml /etc/kubernetes/kubelet.yaml
cp -f ./proxy /etc/kubernetes/proxy

cp -f ./kubelet.service /usr/lib/systemd/system/kubelet.service
cp  -f ./kube-proxy.service /usr/lib/systemd/system/kube-proxy.service
c
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

```

###安装kubelet

在k8s集群中，每个Node节点都会启动kubelet进程，用来处理Master节点下发到本节点的任务，管理Pod和pod中的容器。kubelet会在API Server上注册节点信息，定期向Master汇报节点资源使用情况。

kubelet.service

```
[Unit]
Description=Kube Kubelet Server
After=docker.service
Requires=docker.service
 
[Service]
ExecStart=/usr/local/bin/kubelet --hostname-override=172.20.0.113 --address=172.20.0.113 --kubeconfig=/etc/kubernetes/kubelet.yaml --fail-swap-on=false --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target


```
**注意：此处的的address以及hostname-override都为node结点的ip地址不能使用localhost或者127.0.0.1,否则nmaster结点无法定位到服务**

###安装kube-proxy

kube-proxy是管理service的访问入口，包括集群内Pod到Service的访问和集群外访问service。关于service和pod的概念可以自行网上查看。

kube-proxy.service
```
[Unit]
Description=Kube Kubelet Server
After=docker.service
Requires=docker.service
 
[Service]
ExecStart=/usr/local/bin/kubelet --kubeconfig=/etc/kubernetes/kubelet.yaml --fail-swap-on=false --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target
```

proxy

```
KUBE_PROXY_ARGS="--master=http://52.83.92.216:8080 --logtostderr=false --log-dir=/var/log/kubernetes --v=2"
```

