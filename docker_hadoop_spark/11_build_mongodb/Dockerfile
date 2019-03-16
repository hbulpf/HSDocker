FROM hs_base:v1.0

RUN apt-get update && apt-get install -y libcurl3 openssl

RUN wget http://50125.hnbdata.cn:81/common/hsdocker/mongodb-linux-x86_64-rhel70-4.0.6.tgz -O /tmp/mongodb-linux-x86_64-rhel70-4.0.6.tgz &&\
    tar -zxvf /tmp/mongodb-linux-x86_64-rhel70-4.0.6.tgz && \
    mv mongodb-linux-x86_64-rhel70-4.0.6 /usr/local/mongodb && \
    rm /tmp/mongodb-linux-x86_64-rhel70-4.0.6.tgz

ENV MONGODB_HOME=/usr/local/mongodb
ENV PATH=$PATH:$MONGODB_HOME/bin
