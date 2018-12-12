FROM chellyk-hadoop

COPY mirror/*  /tmp/
COPY spark/*  /tmp/

#install spark
RUN tar -xzvf /tmp/spark-2.1.0-bin-without-hadoop.tgz &&\
    mv spark-2.1.0-bin-without-hadoop /usr/local/spark &&\
    rm /tmp/spark-2.1.0-bin-without-hadoop.tgz

ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:/usr/local/spark/bin

RUN  mv /tmp/slaves  $SPARK_HOME/conf/ && \
     mv /tmp/spark-env.sh $SPARK_HOME/conf/ && \
     mv /tmp/start-spark.sh ~/start-spark.sh && \
     mv /tmp/profile /etc/

RUN chmod +x ~/start-spark.sh
