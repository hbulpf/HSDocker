FROM 202.116.46.215/hsdocker2019/hs_spark-hadoop:v1.0
USER root
WORKDIR /root
COPY hibench/* /tmp/
RUN apt-get -y install bc &&\
    tar -zxvf /tmp/HiBench.tar.gz &&\
    mv /root/HiBench /usr/local/hibench &&\
    rm /tmp/HiBench.tar.gz &&\
    mv /tmp/hadoop.conf /usr/local/hibench/conf/ &&\
    mv /tmp/spark.conf /usr/local/hibench/conf/
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"