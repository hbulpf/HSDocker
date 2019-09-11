# Storm On K8S 部署

## 获取docker镜像
[Storm Docker镜像](../../docker_hadoop_spark/05_build_storm-zookeeper/) 已上传至本地Docker Registry:
```
 
```
获取方式
```

```

## 创建storm集群  
在k8s集群中,使用 yaml 文件创建集群
1. 使用 [storm-master.yaml](./storm-master.yaml) 创建 master 节点
```
kubectl create -f ./storm-master.yaml
```
2. 使用 [storm-slave.yaml](./storm-slave.yaml) 创建 slave 节点
```
kubectl create -f ./storm-slave.yaml  
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

5. 在master所在pod启动storm集群  
```
./start-storm.sh
```  
6. storm的具体使用请见[大数据实验24-25](../experiments)






