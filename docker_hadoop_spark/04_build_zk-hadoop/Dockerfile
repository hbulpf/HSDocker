FROM 202.116.46.215/hsdocker2019/hs_hadoop:v1.0
WORKDIR /root
COPY zookeeper_config/* /tmp/
#install zookeeper
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/zookeeper-3.4.10.tar.gz -O /tmp/zookeeper-3.4.10.tar.gz &&\
    tar -xzvf /tmp/zookeeper-3.4.10.tar.gz &&\
    mv zookeeper-3.4.10 /usr/local/zookeeper &&\
    rm /tmp/zookeeper-3.4.10.tar.gz
ENV ZOOKEEPER_HOME=/usr/local/zookeeper
RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/zoo.cfg $ZOOKEEPER_HOME/conf && \
    mv /tmp/start-zookeeper.sh ~/ && \ 
    mv /tmp/profile /etc/  && \
    ln -s /usr/bin/python2.7 /usr/bin/python && \
     . /etc/profile
RUN mkdir $ZOOKEEPER_HOME/data && \
    echo '1' > $ZOOKEEPER_HOME/data/myid && \
    chmod +x ~/start-zookeeper.sh
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"
