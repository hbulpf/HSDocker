count=2
while(( $count<=5 ))
do
    echo ">>> $count USER NS"
    sh start-apps.sh "user$count"
    let "count++"
done