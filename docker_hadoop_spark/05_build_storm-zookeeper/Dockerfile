FROM 202.116.46.215/hsdocker2019/hs_base:v1.0

WORKDIR /root
COPY zookeeper_config/* /tmp/
COPY storm_config/* /tmp/

#install zookeeper 和 storm
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/zookeeper-3.4.10.tar.gz -O /tmp/zookeeper-3.4.10.tar.gz &&\
    tar -xzvf /tmp/zookeeper-3.4.10.tar.gz &&\
    mv zookeeper-3.4.10 /usr/local/zookeeper &&\
    rm /tmp/zookeeper-3.4.10.tar.gz  &&\
    wget http://50125.hnbdata.cn:81/common/hsdocker/apache-storm-1.1.0.tar.gz -O /tmp/apache-storm-1.1.0.tar.gz &&\
    tar -zxvf /tmp/apache-storm-1.1.0.tar.gz  &&\
    mv apache-storm-1.1.0  /usr/local/storm && \
    rm /tmp/apache-storm-1.1.0.tar.gz

#ssh key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/
ENV ZOOKEEPER_HOME=/usr/local/zookeeper
ENV STORM_HOME=/usr/local/storm
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

#move config
RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/zoo.cfg $ZOOKEEPER_HOME/conf && \
    mv /tmp/start-zookeeper.sh ~/ && \ 
    mv /tmp/profile /etc/  && \
    mv /tmp/storm.yaml $STORM_HOME/conf && \
    mv /tmp/start-storm.sh ~/ &&\
    ln -s /usr/bin/python2.7 /usr/bin/python && \
     . /etc/profile
    
RUN chmod +x ~/start-zookeeper.sh  && \
    chmod +x ~/start-storm.sh

