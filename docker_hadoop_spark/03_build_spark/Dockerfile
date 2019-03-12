FROM hs_hadoop:v1.0

COPY spark_config/*  /tmp/

#install spark
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/spark-2.1.0-bin-without-hadoop.tgz -O /tmp/spark-2.1.0-bin-without-hadoop.tgz && \
	tar -xzvf /tmp/spark-2.1.0-bin-without-hadoop.tgz &&\
    mv spark-2.1.0-bin-without-hadoop /usr/local/spark &&\
    rm /tmp/spark-2.1.0-bin-without-hadoop.tgz

RUN wget http://50125.hnbdata.cn:81/common/hsdocker/scala-2.12.2.tgz -O /tmp/scala-2.12.2.tgz && \
	tar -xzvf /tmp/scala-2.12.2.tgz &&\
    mv scala-2.12.2 /usr/local/scala &&\
    rm /tmp/scala-2.12.2.tgz

ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ENV SPARK_HOME=/usr/local/spark
ENV SCALA_HOME=/usr/local/scala
ENV PATH=$PATH:$SPARK_HOME/bin:$SCALA_HOME/bin

RUN  mv /tmp/slaves  $SPARK_HOME/conf/ && \
     mv /tmp/spark-env.sh $SPARK_HOME/conf/ && \
     mv /tmp/start-spark.sh ~/start-spark.sh && \
     mv /tmp/profile /etc/ && \
     source /etc/profile

RUN chmod +x ~/start-spark.sh
