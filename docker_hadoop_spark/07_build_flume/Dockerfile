FROM hs_flume:v1.0

WORKDIR /root

# install hadoop 2.7.7
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/apache-flume-1.5.2-bin.tar.gz -O /tmp/apache-flume-1.5.2-bin.tar.gz && \
	tar -xzvf /tmp/apache-flume-1.5.2-bin.tar.gz && \
    mv apache-flume-1.5.2-bin /usr/local/flume && \
    rm /tmp/apache-flume-1.5.2-bin.tar.gz
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"
