FROM ubuntu:14.04

WORKDIR /root

RUN apt-get update && apt-get install -y openssh-server wget vim

COPY mirror/* /tmp/
COPY zookeeper/* /tmp/
COPY storm/* /tmp/

#install java
RUN tar -xzvf /tmp/jdk-8u171-linux-x64.tar.gz && \ 
    mv jdk1.8.0_171 /usr/local/java && \
    rm /tmp/jdk-8u171-linux-x64.tar.gz  

#install zookeeper
RUN tar -xzvf /tmp/zookeeper-3.4.10.tar.gz &&\
    mv zookeeper-3.4.10 /usr/local/zookeeper &&\
    rm /tmp/zookeeper-3.4.10.tar.gz 

#install storm
RUN tar -zxvf /tmp/apache-storm-1.1.0.tar.gz  &&\
    mv apache-storm-1.1.0  /usr/local/storm && \
    rm /tmp/apache-storm-1.1.0.tar.gz

#ssh key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# set environment variable
ENV JAVA_HOME=/usr/local/java
ENV ZOOKEEPER_HOME=/usr/local/zookeeper
ENV STORM_HOME=/usr/local/storm

#move config
RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/zoo.cfg $ZOOKEEPER_HOME/conf && \
    mv /tmp/start-zookeeper.sh ~/ && \ 
    mv /tmp/profile /etc/  && \
    mv /tmp/storm.yaml $STORM_HOME/conf && \
    mv /tmp/start-storm.sh ~/
    
RUN chmod +x ~/start-zookeeper.sh  && \
    chmod +x ~/start-storm.sh

CMD [ "sh", "-c", "service ssh start; bash"]
