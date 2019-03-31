echo "Working Dir: $(pwd)"
#get parameters
USERNS=$1
#delete resources if exists
sed hadoop-master.yaml -e "s/hadoop-/$USERNS-hadoop-/g" | kubectl delete -n $USERNS  -f -
sed hadoop-slave.yaml -e "s/hadoop-/$USERNS-hadoop-/g" | kubectl delete -n $USERNS  -f -
sed hadoop-web.yaml -e "s/hadoop-/$USERNS-hadoop-/g" | kubectl delete -n $USERNS -f -
kubectl delete ns $USERNS
#create resources
kubectl create ns $USERNS
sed hadoop-master.yaml -e "s/hadoop-/$USERNS-hadoop-/g" | kubectl create -n $USERNS  -f -
sed hadoop-slave.yaml -e "s/hadoop-/$USERNS-hadoop-/g" | kubectl create -n $USERNS  -f -
sed hadoop-web.yaml -e "s/hadoop-/$USERNS-hadoop-/g" | kubectl create -n $USERNS -f -
#write to /etc/hosts on master
hoststr=$(kubectl get pod -o wide -n $USERNS | grep -i "slave" | awk '{print $6"\t"$1}')
host0="slave-0"
host1="slave-1"
count=0
while :
do
	if [[ $hoststr =~ $host0 && $hoststr =~ $host1 && ! $hoststr =~ "<none>" ]]; then
		echo "write to /etc/hosts"
		kubectl get pod -o wide -n test | grep -i "slave" | awk '{print $6"\t"$1}' > ${USERNS}_hosts_tmp && \
			kubectl cp ${USERNS}_hosts_tmp master:/tmp/hosts_tmp -n test && \
			kubectl exec master -n test -- /bin/sh -c "cat /tmp/hosts_tmp >> /etc/hosts"	
		cat ${USERNS}_hosts_tmp	
		break
	fi
	sleep 1
	((count++))
	echo "$count s:$hoststr"
	hoststr=$(kubectl get pod -o wide -n test | grep -i "slave" | awk '{print $6"\t"$1}')
done

rm ${USERNS}_hosts_tmp
kubectl exec master -n $USERNS -- scp /etc/hosts slave-0:/etc/hosts
kubectl exec master -n $USERNS -- scp /etc/hosts slave-1:/etc/hosts
# start hadoop
kubectl exec master -n $USERNS -- hdfs namenode -format
kubectl exec master -n $USERNS -- start-all.sh

exit 0