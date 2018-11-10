# 安装kubernetes v1.10.1tls版本文档说明
___

## master结点的安装
在master结点运行脚本server_run.sh
#### 证书的生成
```
#主机名字的更改，再添加新的node结点时需要在此处增加hostname
cat >/etc/hosts <<EOM
container-getty@.service                initrd.target                      quotaon.service                    sockets.target.wants                           systemd-rfkill@.service
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
193.112.177.239 master
112.74.186.129 node1
EOM

### 生成ssh密钥并传公钥到各node上
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat id_rsa.pub >> authorized_keys && chmod 644 authorized_keys

### 修改 master节点上的 ~/.ssh/config 文件
cat > ~/.ssh/config << EOF
Host master
   Hostname 193.112.177.239 
   User root
Host node1
   Hostname 112.74.186.129
   User root
EOF

sudo chmod 644 ~/.ssh/config
# 分发密钥
ssh-copy-id -i ~/.ssh/id_rsa.pub root@node1
# 下载生成证书的cfssl软件
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
sudo chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
sudo chmod +x cfssljson_linux-amd64
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
sudo chmod +x cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo

export PATH=/usr/local/bin:$PATH

cp  ./config /etc/kubernetes/config

# 创建 CA 配置文件
mkdir -p ./kubernetes/ssl
cd ./kubernetes/ssl
cfssl print-defaults config > config.json
cfssl print-defaults csr > csr.json
### 根据config.json文件的格式创建如下的ca-config.json文件

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF
### 创建ca-csr.json
cat > ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ],
    "ca": {
       "expiry": "87600h"
    }
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cat > kubernetes-csr.json <<EOF
{
    "CN": "kubernetes",
    "hosts": [
      "127.0.0.1",
      "master",
      "node1",
      "10.254.0.1",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "BeiJing",
            "L": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF

### 生成 kubernetes 证书和私钥
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

### 创建admin-csr.json
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
### 生成 admin 证书和私钥：
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin

### 创建 kube-proxy 证书
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy

### 安装kubectl命令行工具,用于生成配置文件

wget https://dl.k8s.io/v1.10.0/kubernetes-client-linux-amd64.tar.gz
tar -xzvf kubernetes-client-linux-amd64.tar.gz
cp kubernetes/client/bin/kube* /usr/bin/
chmod a+x /usr/bin/kube*

export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

### 创建 kube-proxy kubeconfig 文件
export KUBE_APISERVER="https://master:6443"

###### 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig
  
###### 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig
  
###### 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig
  
###### 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig


###创建 kube-proxy kubeconfig 文件
export KUBE_APISERVER="https://master:6443"
###### 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
###### 设置客户端认证参数
kubectl config set-credentials kube-proxy \
  --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
  --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
###### 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
###### 设置默认上下文
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
###

mkdir -p /etc/kubernetes/ssl
###分发证书
cp -r -f  *.pem /etc/kubernetes/ssl
cp -r -f *.kubeconfig /etc/kubernetes


###分发证书和配置文件s
scp -r /etc/kubernetes root@node1:/etc/

```
* 在kubernetes-csr.json中，如果 hosts 字段不为空则需要指定授权使用该证书的 IP 或域名列表，由于该证书后续被 etcd 集群和 kubernetes master 集群使用，所以上面分别指定了 etcd 集群、kubernetes master 集群的主机 IP 和 kubernetes 服务的服务 IP（一般是 kube-apiserver 指定的 service-cluster-ip-range 网段的第一个IP，如 10.254.0.1）。

***


#### master结点中etcd的安装
运行etcd文件夹下的run.sh脚本

```
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
```
**由于搭建的是etcd集群，所以拷贝的etcd.service中需要包含所有结点的信息，并且根据相应的结点来更改/etc/etcd/etcd.conf的配置文件修改ETCD_NAME，以及相应的hostname**
***

#### master结点中flannel的安装
安装执行脚本为

```

yum remove -y flannel
yum install -y flannel

cp -f ./flanneld.service /usr/lib/systemd/system/flanneld.service

cat > /etc/sysconfig/flanneld <<EOM
# Flanneld configuration options  

# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="https://master:2379,https://node1:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/kube-centos/network"

# Any additional options that you want to pass
FLANNEL_OPTIONS="-etcd-cafile=/etc/kubernetes/ssl/ca.pem -etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem -etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem"
EOM

```
***此处需修改添加所有的etcd结点***
#### master结点中k8s-server的安装
其中包含apiserver，controller-manager，scheduler的安装脚本如下

```
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
```

* 修改apiserver的etcd结点，将所有的etcd结点添加

## node结点的安装

与master结点相同的etcd，docker，flannel安装，

***
### k8s-node的安装
安装包括俩个组件，kubelet与kube-proxy安装脚本如下

```
#!/bin/bash
mkdir -p /etc/kubernetes

sudo setenforce 0

yum install -y wget
wget https://dl.k8s.io/v1.10.0/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz

cd kubernetes
tar -xzvf  kubernetes-src.tar.gz
cp -r ./server/bin/{kube-proxy,kubelet} /usr/local/bin/



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

```
需要修改的部分

* kubelet中的--address，--hostname-override修改成相应结点的主机名或者ip
* proxy中中的--address，--hostname-override修改成相应结点的主机名或者ip
* 如镜像无法下载可替换其他可下载的相同镜像
