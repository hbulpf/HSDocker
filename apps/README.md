# 说明
文件记录了在k8s集群上测试hadoop，spark集群的历次变动。  

## 1.v1
直接建立1个master节点的pod和2个slave节点的pod  

[hadoop-master.yaml](旧版本yaml/v1/hadoop-master.yaml)  
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
      image: 192.168.56.1:5000/chellyk-hadoop:latest
      imagePullPolicy: Never

```  

[hadoop-slave.yaml](旧版本yaml/v1/hadoop-slave.yaml) 
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
      image: 192.168.56.1:5000/chellyk-hadoop:latest
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
      image: 192.168.56.1:5000/chellyk-hadoop:latest
      imagePullPolicy: Never
```

## 2.v2
在v1的基础上新增加了service

[hadoop-master.yaml](旧版本yaml/v2/hadoop-master.yaml)  
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
      image: 192.168.56.1:5000/chellyk-hadoop:latest
      imagePullPolicy: Never
```   
[hadoop-slave.yaml](旧版本yaml/v2/hadoop-slave.yaml)
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
      image: 192.168.56.1:5000/chellyk-hadoop:latest
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
      image: 192.168.56.1:5000/chellyk-hadoop:latest
      imagePullPolicy: Never

```


## 3.v3
在v2的基础上，slave节点的部署选择使用StatefulSets. 新增web-service, 通过Nodeport的方式让外部能够访问hadoop,spark集群的web界面。补上了spark集群的相关yaml。
[hadoop相关yaml](./hadoop_on_k8s)  
[spark相关yaml](./spark_on_k8s)

