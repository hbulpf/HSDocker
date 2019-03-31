count=1
while(( $count<=10 ))
do
    echo ">>> $count USER NS"
    sh start-apps.sh "user$count"
    let "count++"
done