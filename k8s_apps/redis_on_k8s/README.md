# Redis On K8S 部署
特性：
- 带 configmap 
- 带 nfs 永久卷挂载

# 快速使用
快速建立容器的过程
```
kubectl create ns test
kubectl create -f ./nfs/
sh start-apps.sh
```

# 一般使用
一般的配置使用过程
## 获取 Spark 和 redis 镜像
从Harbor上拉取 Spark 镜像 `202.116.46.215/hsdocker2019/hs_spark:latest`   
拉取方式
```
docker pull 202.116.46.215/hsdocker2019/hs_spark:latest  
```

从Harbor上拉取 redis 镜像 `202.116.46.215/hsdocker2019/hs_redis:latest`   
拉取方式
```
docker pull 202.116.46.215/hsdocker2019/hs_redis:latest  
```

## 创建集群
在当前目录下先创建configmap存储hadoop配置文件:
```
kubectl create configmap hadoop --from-file=./hadoop_configmap
```


在k8s集群中,使用 yaml 文件创建集群
1. 使用 [redis-master.yaml](./redis-master.yaml) 创建 master 节点
```
kubectl create -f ./redis-master.yaml
```
2. 使用 [spark-slave.yaml](./spark-slave.yaml) 创建 slave 节点
```
kubectl create -f ./spark-slave.yaml  
```
3. 修改 hosts  
查看各节点的ip
```
kubectl get pod -o wide
```
在hadoop-master所在的 pod 修改hadoop节点的IP
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
4. 在master所在的 pod启动hadoop和spark集群
```
cd ~
./start-hadoop.sh
./start-spark.sh
```  