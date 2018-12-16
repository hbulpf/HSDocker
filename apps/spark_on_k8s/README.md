# Spark On K8S 部署

## 获取docker镜像
docker镜像已上传至本地Docker Registry:
```
192.168.56.1:5000/chellyk-hadoop:latest  
192.168.56.1:5000/chellyk-spark:latest  
```
获取方式
```
docker pull 192.168.56.1:5000/chellyk-hadoop:latest  
docker pull 192.168.56.1:5000/chellyk-spark:latest  
```

## 创建Hadoop 集群
在k8s集群中,使用 yaml 文件创建集群
1. 使用 [hadoop-master.yaml](./hadoop-master.yaml) 创建 hadoop-master 节点
```
kubectl create -f ./hadoop-master.yaml
```
2. 使用 [hadoop-slave.yaml](./hadoop-slave.yaml) 创建 hadoop-slave 节点
```
kubectl create -f ./hadoop-slave.yaml  
```

3. 在各个hadoop节点所在的pod启动ssh
```
kubectl exec -it hadoop-master bash
service ssh start

kubectl exec -it hadoop-slave-0 bash
service ssh start

kubectl exec -it hadoop-slave-1 bash
service ssh start  
```

4. 修改 hosts  
查看各hadoop节点的ip
```
kubectl get pod -o wide
```
在hadoop-master所在的 pod 修改hadoop节点的IP
```
##1.进入 hadoop-master所在的 pod
kubectl exec -it hadoop-master bash
##2.修改/etc/hosts文件  
##3.将/hosts文件分发到slave节点
scp /etc/hosts hadoop-slave-0:/etc/hosts
scp /etc/hosts hadoop-slave-1:/etc/hosts
```
5. 修改hadoop-master所在的 pod的 `/usr/local/hadoop/etc/hadoop/slaves`文件,将内容改为 
```
hadoop-slave-0
hadoop-slave-1 
```
6. 在hadoop-master所在的 pod启动hadoop集群
```
./start-hadoop.sh
```  

## 创建Spark集群  
1. 重复创建hadoop集群里的1~5步骤  
2. 启动HDFS（spark的存储选择使用HDFS）  
```
/usr/local/hadoop/sbin/start-dfs.sh
```  
3. 修改hadoop-master所在的pod的`/usr/local/spark/conf/slaves`文件,将内容改为  
```
hadoop-slave-0
hadoop-slave-1 
```  
4. 在master所在pod启动spark集群  
```
./start-spark.sh
```  
5. Spark的具体使用请见[大数据实验13-19](../experiments)

