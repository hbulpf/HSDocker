# hive On K8S 部署

## 获取docker镜像
[hive Docker镜像](../../hadoopspark/demo_5-new_images/spark/) 已上传至本地Docker Registry:
```
192.168.56.1:5000/chellyk-hive:latest  
```
获取方式
```
docker pull 192.168.56.1:5000/chellyk-hive:latest  
```

## 创建集群  
在k8s集群中,使用 yaml 文件创建集群
1. 使用 [hive-master.yaml](./hive-master.yaml) 创建 master 节点
```
kubectl create -f ./hive-master.yaml
```
2. 使用 [hive-slave.yaml](./hive-slave.yaml) 创建 slave 节点
```
kubectl create -f ./hive-slave.yaml  
```

3. 修改 hosts  
查看各节点的ip
```
kubectl get pod -o wide
```
在master所在的 pod 修改节点的IP
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

4. 启动hadoop  
```
/root/start-hadoop.sh
```  

5. 在master所在pod启动hive,直接键入hive命令即可
```
hive
```  
6. hive的具体使用请见[大数据实验10-12](../experiments)

