#get parameters
NS=$1
SlaveNum=$2
#delete resources if exists
kubectl delete -f storm-slave.yaml -n $NS
kubectl delete -f storm-master.yaml -n $NS
#create resources
kubectl create -f storm-master.yaml -n $NS
kubectl create -f storm-slave.yaml -n $NS
#write to /etc/hosts on master
hoststr=$(kubectl get pod -o wide -n $NS | grep -i "slave" | awk '{print $6"\t"$1}')
host0="slave-0"
host1="slave-1"
count=0
while :
do
	if [[ $hoststr =~ $host0 && $hoststr =~ $host1 && ! $hoststr =~ "<none>" ]]; then
		echo "write to /etc/hosts"
		kubectl get pod -o wide -n $NS | grep -i "slave" | awk '{print $6"\t"$1}' > hosts_tmp && \
			kubectl cp hosts_tmp master:/tmp/hosts_tmp -n $NS && \
			kubectl exec master -n $NS -- /bin/sh -c "cat /tmp/hosts_tmp >> /etc/hosts"	
		cat hosts_tmp	
		break
	fi
	sleep 1
	((count++))
	echo "$count s:$hoststr"
	hoststr=$(kubectl get pod -o wide -n $NS | grep -i "slave" | awk '{print $6"\t"$1}')
done
rm hosts_tmp
kubectl exec master -n $NS -- scp /etc/hosts slave-0:/etc/hosts
kubectl exec master -n $NS -- scp /etc/hosts slave-1:/etc/hosts
kubectl exec $host0 -n $NS -- sh -c "echo '2' > /usr/local/zookeeper/data/myid"
kubectl exec $host1 -n $NS -- sh -c "echo '3' > /usr/local/zookeeper/data/myid"
# start
kubectl exec master -n $NS -- hdfs namenode -format
kubectl exec master -n $NS -- start-all.sh
kubectl exec master -n $NS -- start-zookeeper.sh
kubectl exec master -n $NS -- start-hbase.sh
