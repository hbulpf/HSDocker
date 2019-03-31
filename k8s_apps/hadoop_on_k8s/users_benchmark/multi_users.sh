count=1
while(( $count<=5 ))
do
    echo ">>> $count USER NS"
    sh start-apps.sh "$count"
    let "count++"
done