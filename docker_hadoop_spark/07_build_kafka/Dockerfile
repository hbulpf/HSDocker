FROM hs_storm:v1.0

COPY kafka_2.10-0.9.0.1.tgz /tmp/

RUN wget http://frp.hnbdata.cn:25081/common/hsdocker/kafka_2.10-0.9.0.1.tgz -O /tmp/kafka_2.10-0.9.0.1.tgz &&\
    tar -zxvf /tmp/kafka_2.10-0.9.0.1.tgz && \
    mv kafka_2.10-0.9.0.1 /usr/local/kafka && \
    rm /tmp/kafka_2.10-0.9.0.1.tgz

ENV KAFKA_HOME=/usr/local/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin
