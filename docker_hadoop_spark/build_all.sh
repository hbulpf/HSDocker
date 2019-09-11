cd 01_build_hadoop && docker build --no-cache -t hs_hadoop:v1.0 .
cd ../02_build_hive-hadoop && docker build --no-cache -t hs_hive-hadoop:v1.0  .
cd ../03_build_spark-hadoop && docker docker build --no-cache -t hs_spark-hadoop:v1.0 .
cd ../04_build_zk-hadoop && docker docker build --no-cache  -t hs_zk-hadoop:v1.0  .
cd ../04.1_build_zk && docker build --no-cache  -t hs_zk:v1.0  .
cd ../05_build_hbase-zk-hadoop && docker build --no-cache -t hs_hbase-zk-hadoop:v1.0 .
cd ../06_build_storm-zk && docker build --no-cache  -t hs_storm-zk:v1.0  .
cd ../07_build_flume-hadoop && docker build --no-cache -t hs_flume-hadoop:v1.0 .
cd ../08_build_kafka-zk && docker build --no-cache  -t hs_kafka-zk:v1.0 .
cd ../09_build_pig-hadoop && docker build --no-cache -t hs_pig-hadoop:v1.0 .
cd ../10_build_redis && docker build --no-cache -t hs_redis:v1.0 .
cd ../10.1_build_redis-spark && docker build --no-cache -t hs_redis-spark:v1.0 .
cd ../11_build_mahout-hadoop && docker build --no-cache -t hs_mahout-hadoop:v1.0 .
cd ../12_build_mongodb && docker build --no-cache -t hs_mongodb:v1.0 .
cd ../13_build_leveldb && docker build -t hs_leveldb:v1.0 .

                      