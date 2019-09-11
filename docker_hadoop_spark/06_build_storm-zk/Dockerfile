FROM 202.116.46.215/hsdocker2019/hs_zk:v1.0
WORKDIR /root
COPY storm_config/* /tmp/
#install storm
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/apache-storm-1.1.0.tar.gz -O /tmp/apache-storm-1.1.0.tar.gz &&\
    tar -zxvf /tmp/apache-storm-1.1.0.tar.gz  &&\
    mv apache-storm-1.1.0  /usr/local/storm && \
    rm /tmp/apache-storm-1.1.0.tar.gz
# set environment variable
ENV STORM_HOME=/usr/local/storm
ENV PATH=$PATH:$STORM_HOME/bin
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
#move config
RUN mv /tmp/storm.yaml $STORM_HOME/conf && \
    mv /tmp/start-storm.sh ~/ 
RUN chmod +x ~/start-storm.sh
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"