FROM 202.116.46.215/hsdocker2019/hs_spark-hadoop:v1.0
USER root
WORKDIR /hibench
COPY HiBench/* /hibench/
CMD exec /bin/bash -c "service ssh start;trap : TERM INT; sleep infinity & wait"