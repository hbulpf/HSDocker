**构建 hive-2.3.4 镜像**

>构建hive镜像前先确保构建好前一个hbase镜像

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache -t hs_hive-hadoop:v1.0  .
```

## 2.获取 hive-2.3.4 安装包    
```
wget -O download/apache-hive-2.3.4-bin.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-2.3.4/apache-hive-2.3.4-bin.tar.gz
```   
会下载 hive-2.3.4 安装包并存储在 download 文件夹下
