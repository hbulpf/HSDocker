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
echo "172.30.8.4 hadoop-slave-0" >> /etc/hosts
echo "172.30.7.4 hadoop-slave-1" >> /etc/hosts
##3.将/hosts文件分发到slave节点
scp /etc/hosts hadoop-slave-0:/etc/hosts
scp /etc/hosts hadoop-slave-1:/etc/hosts
```
5. 修改hadoop-master所在的 pod的 `/usr/local/hadoop/etc/hadoop/slaves`文件,将内容改为 
```
cat <<EOF >/usr/local/hadoop/etc/hadoop/slaves
hadoop-slave-0
hadoop-slave-1 
EOF
```
6. 在hadoop-master所在的 pod启动hadoop集群
```
cd ~
./start-hadoop.sh
```  

