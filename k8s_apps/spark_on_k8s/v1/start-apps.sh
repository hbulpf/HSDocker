kubectl create -f spark-master.yaml -n test
kubectl create -f spark-slave.yaml -n test

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
kubectl exec master -n test -- scp /etc/hosts slave-0:/etc/hosts
kubectl exec master -n test -- scp /etc/hosts slave-1:/etc/hosts

kubectl exec master -n test -- start-all.sh
