#!/bin/bash
cat >/etc/hosts <<EOM
container-getty@.service                initrd.target                      quotaon.service                    sockets.target.wants                           systemd-rfkill@.service
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
193.112.177.239 master
112.74.186.129 node1
EOM

sudo alias cp=cp

sudo setenforce 0

mkdir -p /etc/kubernetes

###生成ssh密钥并传公钥到各node上
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat id_rsa.pub >> authorized_keys && chmod 644 authorized_keys

###修改 master节点上的 ~/.ssh/config 文件
cat > ~/.ssh/config << EOF
Host master
   Hostname 193.112.177.239 
   User root
Host node1
   Hostname 112.74.186.129
   User root
EOF

sudo chmod 644 ~/.ssh/config

ssh-copy-id -i ~/.ssh/id_rsa.pub root@node1


#下载生成证书的cfssl软件
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

#创建 CA 配置文件
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
###创建ca-csr.json
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

###生成 kubernetes 证书和私钥
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

###创建admin-csr.json
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
###生成 admin 证书和私钥：
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin

###创建 kube-proxy 证书
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

###安装kubectl命令行工具,用于生成配置文件

wget https://dl.k8s.io/v1.10.0/kubernetes-client-linux-amd64.tar.gz
tar -xzvf kubernetes-client-linux-amd64.tar.gz
cp kubernetes/client/bin/kube* /usr/bin/
chmod a+x /usr/bin/kube*

export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

###创建 kube-proxy kubeconfig 文件
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

cd ..
cd ..
cd ./etcd
./run.sh
cd ..
cd ./flannel
./run.sh

etcdctl --endpoints=https://master:2379,https://node1:2379 \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mkdir /kube-centos/network
etcdctl --endpoints=https://master:2379,https://node1:2379 \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mk /kube-centos/network/config '{"Network":"172.30.0.0/16","SubnetLen":24,"Backend":{"Type":"vxlan"}}'

cd ..
cd ./server
./run.sh
