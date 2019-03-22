FROM hs_storm:v1.0

RUN wget http://50125.hnbdata.cn:81/common/hsdocker/kafka_2.10-0.9.0.1.tgz -O /tmp/kafka_2.10-0.9.0.1.tgz &&\
    tar -zxvf /tmp/kafka_2.10-0.9.0.1.tgz && \
    mv kafka_2.10-0.9.0.1 /usr/local/kafka && \
    rm /tmp/kafka_2.10-0.9.0.1.tgz

ENV KAFKA_HOME=/usr/local/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"