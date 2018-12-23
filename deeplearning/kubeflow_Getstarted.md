# Kubeflow 安装教程 （未完全解决）

> 系统环境： centos7.5

### 1. 启动docker
**安装docker**
注意安装版本docker-ce 17.03

先查看已经安装的docker安装版本
```shell
$ yum list installed | grep docker

如果存在docker-ce而且不是17.03版本，移除掉
```shell
$ yum -y remove docker*
$ yum -y remove containerd.io.x86_64
$ rm -rf /var/lib/docker
```

添加源，并查看可以安装版本

```shell
$ sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
$ sudo yum list docker-ce --showduplicates
```

安装

```shell
$ yum install -y --setopt=obsoletes=0 docker-ce-17.03.2.ce-1.el7.centos.x86_64 docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch
```
（如果报错，可能需要移除类似的selinux）

```shell
$ yum -y remove container-selinux-2.74-1.el7.noarch
```

启动docker

```shell
$ sudo systemctl restart docker
```

### 2. 启动minikube
运行minikube启动脚本

**minikube.sh**
```shell
BASE_DIR=.tools/k8s
MINIKUBE_VERSION=v0.28.0
MINIKUBE_K8S_VERSION=v1.10.0
MINIKUBE_BIN=${BASE_DIR}/minikube-${MINIKUBE_VERSION}

echo "Making sure that ${BASE_DIR} directory exists"
mkdir -p ${BASE_DIR}

echo "Downloading minikube ${MINIKUBE_VERSION} if it is not cached"
curl -Lo minikube http://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64 \
&& chmod +x minikube && sudo mv minikube ${MINIKUBE_BIN}

echo "Making sure that kubeconfig file exists and will be used by Dashboard"
mkdir -p $HOME/.kube
touch $HOME/.kube/config

echo "Starting minikube"
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=${HOME}
export CHANGE_MINIKUBE_NONE_USER=true
sudo -E ${MINIKUBE_BIN} start --registry-mirror=https://registry.docker-cn.com \
--vm-driver=none \
--kubernetes-version ${MINIKUBE_K8S_VERSION}
```

### 3. 安装kubectl
```shell
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
$ yum list kubectl –showduplicates
$ yum install -y kubectl.x86_64
```

查看kubectl安装是否成功

```shell
$ kubectl version
```

查看minikube是否成功启动
```shell
$ kubectl cluster-info
```
成功启动会显示
```
Kubernetes master is running at https://192.168.46.131:8443
```

### 4. 安装ksonnet
