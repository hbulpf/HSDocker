FROM chellyk-hbase
COPY hive/* /tmp/

RUN tar -zxvf /tmp/apache-hive-1.2.2-bin.tar.gz && \
    mv apache-hive-1.2.2-bin /usr/local/hive && \
    rm /tmp/apache-hive-1.2.2-bin.tar.gz

ENV HIVE_HOME=/usr/local/hive
ENV PATH=$PATH:/usr/local/hive/bin

RUN mv /tmp/hive-env.sh $HIVE_HOME/conf && \
    mv /tmp/hive-site.xml $HIVE_HOME/conf && \
    mv /tmp/hive-log4j.properties $HIVE_HOME/conf && \
    mv /tmp/mysql-connector-java-5.1.32-bin.jar $HIVE_HOME/lib




