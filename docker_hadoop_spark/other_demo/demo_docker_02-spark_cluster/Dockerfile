FROM ubuntu:14.04

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server wget vim

COPY mirror/* /tmp/

# install java
RUN tar -xzvf /tmp/jdk-8u171-linux-x64.tar.gz && \
    mv jdk1.8.0_171 /usr/local/java && \
    rm /tmp/jdk-8u171-linux-x64.tar.gz

# install hadoop 2.7.2
RUN tar -xzvf /tmp/hadoop-2.7.2.tar.gz && \
    mv hadoop-2.7.2 /usr/local/hadoop && \
    rm /tmp/hadoop-2.7.2.tar.gz

# install scala
RUN tar -xzvf /tmp/scala-2.12.2.tgz && \
    mv scala-2.12.2 /usr/local/scala && \
    rm /tmp/scala-2.12.2.tgz

#install spark
RUN tar -xzvf /tmp/spark-2.1.0-bin-hadoop2.7.tgz &&\
    mv spark-2.1.0-bin-hadoop2.7 /usr/local/spark &&\
    rm /tmp/spark-2.1.0-bin-hadoop2.7.tgz

# set environment variable
ENV JAVA_HOME=/usr/local/java
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 
ENV SPARK_HOME=/usr/local/spark


# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY hadoop/* /tmp/

COPY spark/*  /spark/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/profile /etc/  && \
    mv /spark/slaves  $SPARK_HOME/conf/ && \
    mv /spark/spark-env.sh $SPARK_HOME/conf/ && \
    mv /spark/start-spark.sh ~/start-spark.sh
    
RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x ~/start-spark.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]
