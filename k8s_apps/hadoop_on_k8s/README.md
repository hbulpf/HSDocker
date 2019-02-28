# hadoop on k8s 的yaml的历史变动

## [版本v1](./v1/)
直接建立1个master节点的pod和2个slave节点的pod  

[hadoop-master.yaml](./v1/hadoop-master.yaml)  
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

[hadoop-slave.yaml](./v1/hadoop-slave.yaml) 
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

## [版本v2](./v2/)
在v1的基础上新增加了service

[hadoop-master.yaml](./v2/hadoop-master.yaml)  
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
[hadoop-slave.yaml](./v2/hadoop-slave.yaml)
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


## [版本v3](./v3/) （当前使用版本）
在v2的基础上，[版本v3](./v3/)中slave节点的部署选择使用StatefulSets. 新增web-service, 通过Nodeport的方式让外部能够访问hadoop集群的web界面。  


