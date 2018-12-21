# Spark On K8S 部署

## 获取docker镜像
docker镜像已上传至本地Docker Registry:
```
192.168.56.1:5000/chellyk-spark:latest  
```
获取方式
```
docker pull 192.168.56.1:5000/chellyk-spark:latest  
```

## 创建Spark集群  
在k8s集群中,使用 yaml 文件创建集群
1. 使用 [spark-master.yaml](./spark-master.yaml) 创建 master 节点
```
kubectl create -f ./spark-master.yaml
```
2. 使用 [spark-slave.yaml](./spark-slave.yaml) 创建 slave 节点
```
kubectl create -f ./spark-slave.yaml  
```

3. 修改 hosts  
查看各spark节点的ip
```
kubectl get pod -o wide
```
在spark-master所在的 pod 修改spark节点的IP
```
##1.进入 master所在的 pod
kubectl exec -it master bash
##2.修改/etc/hosts文件  
echo "172.30.8.4 slave-0" >> /etc/hosts
echo "172.30.7.4 slave-1" >> /etc/hosts
##3.将/hosts文件分发到slave节点
scp /etc/hosts slave-0:/etc/hosts
scp /etc/hosts slave-1:/etc/hosts
```

4. 启动HDFS（spark的存储选择使用HDFS）  
```
/usr/local/hadoop/sbin/start-dfs.sh
```  

5. 在master所在pod启动spark集群  
```
./start-spark.sh
```  
6. Spark的具体使用请见[大数据实验13-19](../experiments)

