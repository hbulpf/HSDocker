kubectl create -f storm-master.yaml -n test
kubectl create -f storm-slave.yaml -n test

#write to /etc/hosts on master
hoststr=$(kubectl get pod -o wide -n test | grep -i "slave" | awk '{print $6"\t"$1}')
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
kubectl exec master -n test -- . /etc/profile
kubectl exec master -n test -- export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
# scp /etc/hosts to slaves
kubectl exec master -n test -- scp /etc/hosts slave-0:/etc/hosts
kubectl exec master -n test -- scp /etc/hosts slave-1:/etc/hosts


kubectl exec master -n test -- /bin/sh -c 'echo "1" > /usr/local/zookeeper/data/myid'
kubectl exec slave-0 -n test -- /bin/sh -c 'echo "2" > /usr/local/zookeeper/data/myid'
kubectl exec slave-1 -n test -- /bin/sh -c 'echo "3" > /usr/local/zookeeper/data/myid'
