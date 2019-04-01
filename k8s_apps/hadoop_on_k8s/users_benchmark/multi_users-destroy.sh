count=1
while(( $count<=20 ))
do
    echo ">>> $count USER NS"
    sh destroy-apps.sh "user$count"
    let "count++"
done