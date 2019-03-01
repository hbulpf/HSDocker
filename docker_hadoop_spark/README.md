**构建 大数据组件 镜像**

## 一. [制作 Hadoop 镜像](./01_build_hadoop/)
在 Hadoop 镜像的 [Dockerfile](./01_build_hadoop/Dockerfile) 所在目录  
```
docker build -t hs_hadoop:v1.0 .
```

## 二. [制作 Spark 镜像](./02_build_spark/)

Spark 镜像构建 **基于前面的 Hadoop 镜像**,在 Spark 镜像的 [Dockerfile](./02_build_spark/Dockerfile) 文件所在目录  
 
```
docker build -t hs_spark:v1.0 .
```

## 三. [制作 HBase 镜像](./03_build_hbase/)
HBase 镜像构建 **基于前面的  Spark 镜像**,在 HBase 镜像的 [Dockerfile](./03_build_hbase/Dockerfile) 文件所在目录  
```
docker build -t hs_hbase:v1.0 .
```

## 四. [制作 Hive 镜像](./04_build_hive/)
Hive 镜像构建 **基于前面的  HBase 镜像**,在 Hive 镜像的 [Dockerfile](04_build_hive/Dockerfile) 文件所在目录  
```
docker build -t hs_hive:v1.0  .
```

## 五. [制作 Storm 镜像](./05_build_storm-zookeeper/)
该镜像与前面的四个镜像无关，可直接构建,在 storm 镜像的 [Dockerfile](05_build_storm-zookeeper/Dockerfile) 文件所在目录  
```
docker build -t hs_storm:v1.0  .
```



