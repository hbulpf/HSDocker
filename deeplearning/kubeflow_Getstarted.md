# Kubeflow 安装教程 （未完全解决）

> 系统环境： centos7.5

### 1. 启动docker
**安装docker**

注意安装版本docker-ce 17.03

```shell
$ yum list installed | grep docker
```
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
（如果报错，可能需要移除类似的selinux，再按上面指令安装）

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
从下面链接下载对应系统的可执行文件：https://github.com/ksonnet/ksonnet/releases

添加到环境变量，把下载的可执行文件(ks)放入/usr/local/bin，修改文件
```shell
$ vi /etc/profile
```
添加一行
```shell
export PATH="$PATH:/usr/local/bin"
```

立即生效

```shell
$ source /etc/profile
```
验证是否安装成功ksonnet
```shell
$ ks --help
```

### 5.安装kubeflow
原教程见https://www.kubeflow.org/docs/started/getting-started/

Requirements:
- ksonnet version 0.11.0 or later.
- Kubernetes 1.8 or later
- kubectl

先需要指定几个环境变量
- KUBEFLOW_SRC： a directory where you want to download the source to
- KUBEFLOW_TAG： a tag corresponding to the version to check out, such as master for the latest code.
- KFAPP: a directory where you want kubeflow configurations to be stored. This directory will be created when you run init.

这里修改/etc/profile添加下面几行(目录以个人指定为准)
```shell
export KUBEFLOW_SRC=/home/icepoint/kubeflow_src
export KUBEFLOW_TAG=v0.3.4
export KFAPP=/home/icepoint/kfapp
```
环境变量生效后

Run the following commands to download kfctl.sh
```shell
$ mkdir ${KUBEFLOW_SRC}
$ cd ${KUBEFLOW_SRC}

$ curl https://raw.githubusercontent.com/kubeflow/kubeflow/${KUBEFLOW_TAG}/scripts/download.sh | bash
```

Run the following commands to setup and deploy Kubeflow:
```shell
$ ${KUBEFLOW_SRC}/scripts/kfctl.sh init ${KFAPP} --platform none
```
上一步会在${KFAPP}目录里生成env.sh，用于启动ks_app
```shell
$ cd ${KFAPP}
```
```shell
$ ${KUBEFLOW_SRC}/scripts/kfctl.sh generate k8s
$ ${KUBEFLOW_SRC}/scripts/kfctl.sh apply k8s
```
The ksonnet app will be created in the directory ${KFAPP}/ks_app

### Issues:
在启动minikube之后集群可以正常运行，但是启动kubeflow之后也就是运行generate命令之后，再运行apply会有如下报错：
```
kubectl create namespace kubeflow
The connection to the server 192.168.46.131:8443 was refused - did you specify the right host or port?

```
推测： 可能是generate命令把minikube原来的端口占用了