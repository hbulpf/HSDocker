count=1
while(( $count<=5 ))
do
    echo ">>> $count USER NS"
    sh destroy-apps.sh.sh "user$count"
    let "count++"
done