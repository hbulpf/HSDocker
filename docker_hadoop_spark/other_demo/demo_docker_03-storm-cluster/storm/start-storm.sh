#!/bin/bash
    
N=${1:-3}

echo "start storm"

/usr/local/storm/bin/storm nimbus >/dev/null 2>&1 &
/usr/local/storm/bin/storm ui >/dev/null 2>&1 &

i=1
while [ $i -lt $N ]
do
	ssh hadoop-slave$i "source /etc/profile ; /usr/local/storm/bin/storm supervisor >/dev/null 2>&1 & "
	i=$(( $i + 1 ))
done

