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
1. 使用 [spark-master.yaml](./spark-master.yaml) 创建 spark-master 节点
```
kubectl create -f ./spark-master.yaml
```
2. 使用 [spark-slave.yaml](./spark-slave.yaml) 创建 spark-slave 节点
```
kubectl create -f ./spark-slave.yaml  
```

3. 在各个spark节点所在的pod启动ssh
```
kubectl exec -it spark-master bash
service ssh start
kubectl exec -it spark-slave-0 bash
service ssh start
kubectl exec -it spark-slave-1 bash
service ssh start  
```

4. 修改 hosts  
查看各spark节点的ip
```
kubectl get pod -o wide
```
在spark-master所在的 pod 修改hadoop节点的IP
```
##1.进入 spark-master所在的 pod
kubectl exec -it spark-master bash
##2.修改/etc/hosts文件  
echo "172.30.8.4 spark-slave-0" >> /etc/hosts
echo "172.30.7.4 spark-slave-1" >> /etc/hosts
##3.将/hosts文件分发到slave节点
scp /etc/hosts spark-slave-0:/etc/hosts
scp /etc/hosts spark-slave-1:/etc/hosts
```

5. 修改spark-master所在的pod的`/usr/local/hadoop/etc/hadoop/slaves`文件
```
cat <<EOF > /usr/local/hadoop/etc/hadoop/slaves
spark-slave-0
spark-slave-1 
EOF
```  
6. 启动HDFS（spark的存储选择使用HDFS）  
```
/usr/local/hadoop/sbin/start-dfs.sh
```  
7. 修改spark-master所在的pod的`/usr/local/spark/conf/slaves`文件,将内容改为  
```
spark-slave-0
spark-slave-1 
```  
8. 在master所在pod启动spark集群  
```
./start-spark.sh
```  
9. Spark的具体使用请见[大数据实验13-19](../experiments)

