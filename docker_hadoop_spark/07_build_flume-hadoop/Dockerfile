FROM 202.116.46.215/hsdocker2019/hs_hadoop:v1.0
WORKDIR /root
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/apache-flume-1.5.2-bin.tar.gz -O /tmp/apache-flume-1.5.2-bin.tar.gz && \
	tar -xzvf /tmp/apache-flume-1.5.2-bin.tar.gz && \
    mv apache-flume-1.5.2-bin /usr/local/flume && \
    rm /tmp/apache-flume-1.5.2-bin.tar.gz
ENV FLUME_HOME=/usr/local/flume
ENV PATH=$PATH:$FLUME_HOME/bin
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"
