#get parameters
USERNS=$1
WORKDIR=$(pwd)/
echo "Working Dir: ${WORKDIR}"
#delete resources if exists
sed ${WORKDIR}hadoop-master.yaml -e "s/hadoop-/${USERNS}-hadoop-/g" | kubectl delete -n ${USERNS} -f -
sed ${WORKDIR}hadoop-slave.yaml -e "s/hadoop-/${USERNS}-hadoop-/g" | kubectl delete -n ${USERNS} -f -
sed hadoop-web.yaml -e "s/hadoop-/${USERNS}-hadoop-/g" | kubectl delete -n ${USERNS} -f -
kubectl delete ns ${USERNS}
exit 0