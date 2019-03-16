# Storm On K8S 部署

## 获取docker镜像
[Storm Docker镜像](../../docker_hadoop_spark/07_build_kafka/) 已上传至本地Docker Registry:
```
 
```
获取方式
```

```

## 创建集群  
在k8s集群中,使用 yaml 文件创建集群
1. 使用 [kafka-master.yaml](./kafka-master.yaml) 创建 master 节点
```
kubectl create -f ./kafka-master.yaml
```
2. 使用 [kafka-slave.yaml](./kafka-slave.yaml) 创建 slave 节点
```
kubectl create -f ./kafka-slave.yaml  
```

3. 修改 hosts  
查看各storm节点的ip
```
kubectl get pod -o wide
```
在storm-master所在的 pod 修改storm节点的IP
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

4. 启动zookeeper
```
./start-zookeeper.sh
```  

5. kafka的具体使用请见[大数据实验27](../experiments)






