FROM hs_hadoop:v1.0
COPY hive_config/* /tmp/
RUN wget http://50125.hnbdata.cn:81/common/hsdocker/apache-hive-2.3.4-bin.tar.gz -O /tmp/apache-hive-2.3.4-bin.tar.gz && \
	tar -zxvf /tmp/apache-hive-2.3.4-bin.tar.gz && \
    mv apache-hive-2.3.4-bin /usr/local/hive && \
    rm /tmp/apache-hive-2.3.4-bin.tar.gz
ENV HIVE_HOME=/usr/local/hive
ENV PATH=$PATH:$HIVE_HOME/bin
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
RUN mv /tmp/hive-env.sh $HIVE_HOME/conf && \
    mv /tmp/hive-site.xml $HIVE_HOME/conf && \
    mv /tmp/hive-log4j.properties $HIVE_HOME/conf && \
    mv /tmp/mysql-connector-java-5.1.32-bin.jar $HIVE_HOME/lib && \
    . /etc/profile
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"