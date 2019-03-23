FROM 202.116.46.215/hsdocker2019/hs_hadoop:v1.0
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/pig-0.17.0.tar.gz -O /tmp/pig-0.17.0.tar.gz &&\
    tar -zxvf /tmp/pig-0.17.0.tar.gz && \
    mv pig-0.17.0 /usr/local/pig && \
    rm /tmp/pig-0.17.0.tar.gz
ENV PIG_HOME=/usr/local/pig
ENV PATH=$PATH:$PIG_HOME/bin
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"