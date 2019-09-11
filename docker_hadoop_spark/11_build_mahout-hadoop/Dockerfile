FROM 202.116.46.215/hsdocker2019/hs_hadoop:v1.0
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/mahout-distribution-0.9.tar.gz -O /tmp/mahout-distribution-0.9.tar.gz &&\
    tar -zxvf /tmp/mahout-distribution-0.9.tar.gz && \
    mv mahout-distribution-0.9 /usr/local/mahout && \
    rm /tmp/mahout-distribution-0.9.tar.gz
ENV MAHOUT_HOME=/usr/local/mahout
ENV PATH=$PATH:$MAHOUT_HOME/bin
ENV CLASSPATH=.:$MAHOUT_HOME/lib
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"