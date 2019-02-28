FROM chellyk-spark

COPY Hbase/* /tmp/

RUN wget http://50125.hnbdata.cn:81/common/hsdocker/hbase-1.2.6-bin.tar.gz -O /tmp/hbase-1.2.6-bin.tar.gz && \
	tar -zxvf /tmp/hbase-1.2.6-bin.tar.gz && \
    mv hbase-1.2.6 /usr/local/hbase && \
    rm /tmp/hbase-1.2.6-bin.tar.gz

ENV HBASE_HOME=/usr/local/hbase
ENV PATH=$PATH:/usr/local/hbase/bin

RUN mv /tmp/hbase-env.sh $HBASE_HOME/conf && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf && \
    mv /tmp/regionservers $HBASE_HOME/conf 

