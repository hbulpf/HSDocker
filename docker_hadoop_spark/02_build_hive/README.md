**构建 hive-1.2.2 镜像**

>构建hive镜像前先确保构建好前一个hbase镜像

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build -t hs_hive:v1.0  .
```

## 2.获取 hive-1.2.2 安装包    
```
wget -O download/apache-hive-1.2.2-bin.tar.gz https://www-eu.apache.org/dist/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz
```   
会下载 hive-1.2.2 安装包并存储在 download 文件夹下



