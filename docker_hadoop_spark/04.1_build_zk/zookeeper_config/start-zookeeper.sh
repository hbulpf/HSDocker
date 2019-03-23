#!/bin/bash

N=${1:-2}

echo "start zkServer..."

source /etc/profile
mkdir /usr/local/zookeeper/data
touch /usr/local/zookeeper/data/myid
echo "0" > /usr/local/zookeeper/data/myid
/usr/local/zookeeper/bin/zkServer.sh start

i=0
while [ $i -lt $N ]
do
	 ssh slave-$i "source /etc/profile; mkdir /usr/local/zookeeper/data ; touch /usr/local/zookeeper/data/myid ;
				         echo $(($i+1)) > /usr/local/zookeeper/data/myid ; /usr/local/zookeeper/bin/zkServer.sh start "
	 i=$(( $i + 1 ))
done

