FROM hs_base:v1.0

RUN apt-get update && apt-get install -y g++ make

RUN wget http://frp.hnbdata.cn:25081/common/hsdocker/leveldb_v1.20.tar.gz -O /tmp/leveldb_v1.20.tar.gz &&\
    tar -zxvf /tmp/leveldb_v1.20.tar.gz && \
    mv leveldb_v1.20 /usr/local/leveldb && \
    rm /tmp/leveldb_v1.20.tar.gz  &&\
    cd /usr/local/leveldb &&\
    make && \
    cp -r usr/local/leveldb/include/ /usr/include/ &&\
    cp usr/local/leveldb/out-shared/libleveldb.so.1.20 /usr/lib/ &&\
    ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so.1 &&\
    ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so &&\
    ldconfig

ENV LEVELDB_HOME=/usr/local/leveldb
ENV PATH=$PATH:$LEVELDB_HOME/bin