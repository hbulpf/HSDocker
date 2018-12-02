# Minikube 操作记录  

## 1.关于上次的CrashLoopBackoff的解决:  
关于CrashLoopBackoff的解决方案:  
在stack overflow上找到解答:  
**The issue caused by the docker container which exits as soon as the "start" process finishes. Add a command that runs forever and probably it'll work. For example, recreating docker image**:  
在Dockerfile上在底层hadoop镜像的基础上加个:  
```
CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
```  
原镜像的最后一行是通过CMD启动ssh service,原因应该是启动完后pod就自动结束了，然后再重复启动，结束造成死循环。解决办法就是加个命令让容器始终在运作。  

## 2.成功启动pod后
之后Pod可以成功运行起来，开了个master节点的pod和两个slave节点的pod。  
hadoop-master.yaml:  
```
apiVersion: v1
kind: Pod
metadata:
  name: hadoop-master
  labels:
    app: hadoop-master
spec:
  containers:
    - name: hadoop-master
      image: chellyk-spark2
      imagePullPolicy: Never
```  
hadoop-slave.yaml:  
```
apiVersion: v1
kind: Pod
metadata:
  name: hadoop-slave1
  labels:
    app: hadoop-slave
spec:
  containers:
    - name: hadoop-slave1
      image: chellyk-spark2
      imagePullPolicy: Never
---
apiVersion: v1
kind: Pod
metadata:
  name: hadoop-slave2
  labels:
    app: hadoop-slave
spec:
  containers:
    - name: hadoop-slave2
      image: chellyk-spark2
      imagePullPolicy: Never
```  

相对于原先用脚本启动hadoop集群，少了bridge网桥，只能手动添加ip 跟主机名的映射到各个节点的/etc/hosts文件. 在启动过程中发现ssh无法登陆，最后发现是ssh service没启动，原因不明？因为原镜像的最后一行CMD就是启动ssh service。  

手动在三个节点service ssh start，修改/etc/hosts文件后，可以正常启动集群，正常使用wordcount单词计数。  

master节点ip是172.17.0.5  
浏览器通过172.17.0.5:8088 , 172.17.0.5:50070可以正常通过web查看集群情况
(在写yaml时我故意没有加端口映射，但却能正常访问这些端口？很奇怪)  

## 3.稍作改进的yaml  
hadooop-master.yaml:  
```
apiVersion: v1
kind: Service
metadata:
  name: hadoop-nn-service
  labels:
    app: hadoop-nn
spec:
  ports:
    - port: 9000
      name: hdfs
    - port: 50070
      name: name-node
  clusterIP: None
  selector:
    app: hadoop-master
---
apiVersion: v1
kind: Pod
metadata:
  name: hadoop-master
  labels:
    app: hadoop-master
spec:
  containers:
    - name: hadoop-master
      image: chellyk-spark2
      imagePullPolicy: Never
```  

hadoop-slave.yaml: 
```
apiVersion: v1
kind: Service
metadata:
  name: hadoop-dn-service
  labels:
    app: hadoop-dn
spec:
  ports:
    - port: 9000
      name: hdfs
    - port: 50010
      name: data-node-trans
    - port: 50075
      name: data-node-http
  clusterIP: None
  selector:
    app: hadoop-slave
---
apiVersion: v1
kind: Pod
metadata:
  name: hadoop-slave1
  labels:
    app: hadoop-slave
spec:
  containers:
    - name: hadoop-slave1
      image: chellyk-spark2
      imagePullPolicy: Never
---
apiVersion: v1
kind: Pod
metadata:
  name: hadoop-slave2
  labels:
    app: hadoop-slave
spec:
  containers:
    - name: hadoop-slave2
      image: chellyk-spark2
      imagePullPolicy: Never
```  

hadoop-web.yaml:  
```
apiVersion: v1
kind: Service
metadata:
  name: hadoop-ui-service
  labels:
    app: hadoop-nn
spec:
  ports:
    - port: 8088
      name: resource-manager
    - port: 50070
      name: name-node
  selector:
    app: hadoop-nn
  type: NodePort
```  

## 4.测试statefulSet:  
```
apiVersion: v1
kind: Service
metadata:
  name: hadoop-dn-service
  labels:
    app: hadoop-dn
spec:
  ports:
    - port: 9000
      name: hdfs
    - port: 50010
      name: data-node-trans
    - port: 50075
      name: data-node-http
  clusterIP: None
  selector:
    app: hadoop-slave
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: hadoop-slave
spec:
  replicas: 2
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: hadoop-slave
  serviceName: hadoop-dn-service
  template:
    metadata:
      labels:
        app: hadoop-slave
    spec:
      containers:
        - name: hadoop-slave
          image: chellyk-spark2
          imagePullPolicy: Never
```  

指定起两个slave节点的pod。
metadata将name设置成hadoop-slave，生成两个容器的主机名有规律: 
hadoop-slave-0  
hadoop-slave-0  

经测试可以正常使用 

## 5.还存在的问题  
1.每次启动集群都需要在/etc/hosts文件填各节点ip 主机名的映射。
2.因为这只是一个3节点的hadoop集群。如果是要建立大数据实验平台，肯定是要建立多个3节点的hadoop集群，如何将各个集群隔离开，怎么区分？










