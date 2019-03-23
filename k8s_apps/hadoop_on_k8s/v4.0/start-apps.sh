#get parameters
NS=$1
SlaveNum=$2
#delete resources if exists
kubectl delete -f . -n $NS
kubectl delete configmap hadoop-config -n $NS
#create resources
kubectl create configmap hadoop-config -n $NS --from-file=./hadoop_configmap
kubectl create -f hadoop-master.yaml -n $NS
kubectl create -f hadoop-slave.yaml -n $NS
kubectl create -f hadoop-web.yaml -n $NS
#write to /etc/hosts on master
hoststr=$(kubectl get pod -o wide -n $NS | grep -i "slave" | awk '{print $6"\t"$1}')
host0="slave-0"
host1="slave-1"
count=0
while :
do
	if [[ $hoststr =~ $host0 && $hoststr =~ $host1 && ! $hoststr =~ "<none>" ]]; then
		echo "write to /etc/hosts"
		kubectl get pod -o wide -n test | grep -i "slave" | awk '{print $6"\t"$1}' > hosts_tmp && \
			kubectl cp hosts_tmp master:/tmp/hosts_tmp -n test && \
			kubectl exec master -n test -- /bin/sh -c "cat /tmp/hosts_tmp >> /etc/hosts"	
		cat hosts_tmp	
		break
	fi
	sleep 1
	((count++))
	echo "$count s:$hoststr"
	hoststr=$(kubectl get pod -o wide -n test | grep -i "slave" | awk '{print $6"\t"$1}')
done

rm hosts_tmp
kubectl exec master -n $NS -- scp /etc/hosts slave-0:/etc/hosts
kubectl exec master -n $NS -- scp /etc/hosts slave-1:/etc/hosts
# start hadoop
kubectl exec master -n $NS -- mkdir -p /root/hdfs/datanode
kubectl exec master -n $NS -- mkdir -p /root/hdfs/namenode
kubectl exec $host0 -n $NS -- mkdir -p /root/hdfs/datanode
kubectl exec $host1 -n $NS -- mkdir -p /root/hdfs/namenode
kubectl exec $host0 -n $NS -- mkdir -p /root/hdfs/datanode
kubectl exec $host1 -n $NS -- mkdir -p /root/hdfs/namenode
kubectl exec master -n $NS -- hdfs namenode -format
kubectl exec master -n $NS -- start-all.sh
