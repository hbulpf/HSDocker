FROM hs_spark:v1.0

RUN apt-get update && apt-get install -y gcc make

RUN wget http://50125.hnbdata.cn:81/common/hsdocker/redis-4.0.13.tar.gz -O /tmp/redis-4.0.13.tar.gz &&\
    tar -zxvf /tmp/redis-4.0.13.tar.gz && \
    mv redis-4.0.13 /usr/local/redis && \
    rm /tmp/redis-4.0.13.tar.gz &&\
    cd /usr/local/redis &&\
    make &&\
    make install

ENV REDIS_HOME=/usr/local/redis
ENV PATH=$PATH:$REDIS_HOME/bin
