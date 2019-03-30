FROM 202.116.46.215/hsdocker2019/hs_spark-hadoop:v1.0
USER root
ADD http://50125.hnbdata.cn:81/common/hsdocker/HiBench.tar.gz /
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"