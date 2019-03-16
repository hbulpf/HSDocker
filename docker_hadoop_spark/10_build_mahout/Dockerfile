FROM hs_hadoop:v1.0

RUN wget http://frp.hnbdata.cn:25081/common/hsdocker/mahout-distribution-0.9.tar.gz -O /tmp/mahout-distribution-0.9.tar.gz &&\
    tar -zxvf /tmp/mahout-distribution-0.9.tar.gz && \
    mv mahout-distribution-0.9 /usr/local/mahout && \
    rm /tmp/mahout-distribution-0.9.tar.gz

ENV MAHOUT_HOME=/usr/local/mahout
ENV PATH=$PATH:$MAHOUT_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.2.jar:$MAHOUT_HOME/lib
