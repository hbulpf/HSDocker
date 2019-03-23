**HBase On K8S 部署**

# 快速使用
快速建立容器的过程
```
kubectl create ns test
sh start-apps.sh
```
其中，获取docker镜像方式
```
docker pull 202.116.46.215/hsdocker2019/hs_hbase-zk-hadoop:v1.0 
```

## 创建Spark集群  
在k8s集群中,使用 yaml 文件创建集群
1. 使用 [hbase-master.yaml](./hbase-master.yaml) 创建 master 节点
```
kubectl create -f ./hbase-master.yaml
```
2. 使用 [hbase-slave.yaml](./hbase-slave.yaml) 创建 slave 节点
```
kubectl create -f ./hbase-slave.yaml  
```

3. 修改 hosts  
查看各节点的ip
```
kubectl get pod -o wide
```
在hbase-master所在的 pod 修改spark节点的IP
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

4. 启动hdfs（HBase的底层存储选择使用HDFS）  
```
/usr/local/hadoop/sbin/start-dfs.sh
```  

5. 在master所在pod启动HBase集群  
```
/usr/local/hbase/bin/start-hbase.sh
```  
6. HBase的具体使用请见[大数据实验22-23](../experiments)

