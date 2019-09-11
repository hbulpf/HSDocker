**构建kafka-2.10-0.9.0.1镜像**

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache  -t hs_kafka-zk:v1.0 .
```

## 2. 如需获取kafka安装包    
```
wget http://50125.hnbdata.cn:81/common/hsdocker/kafka_2.10-0.9.0.1.tgz -O /download/kafka_2.10-0.9.0.1.tgz 
```   
会下载 kafka_2.10-0.9.0.1.tgz 安装包并存储在 download 文件夹下


