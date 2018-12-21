# Hadoop On K8S 部署 (v3)

## 获取docker镜像
docker镜像已上传至本地Docker Registry:
```
192.168.56.1:5000/chellyk-hadoop:latest  
```
获取方式
```
docker pull 192.168.56.1:5000/chellyk-hadoop:latest  
```

## 创建Hadoop 集群
在k8s集群中,使用 yaml 文件创建集群
1. 使用 [hadoop-master.yaml](./hadoop-master.yaml) 创建 master 节点
```
kubectl create -f ./hadoop-master.yaml
```
2. 使用 [hadoop-slave.yaml](./hadoop-slave.yaml) 创建 slave 节点
```
kubectl create -f ./hadoop-slave.yaml  
```
3. 修改 hosts  
查看各hadoop节点的ip
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
4. 在master所在的 pod启动hadoop集群
```
cd ~
./start-hadoop.sh
```  

