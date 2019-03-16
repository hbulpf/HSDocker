**构建 hadoop-2.7.7 镜像**

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache -t hs_flume:v1.0 .
```

## 2. 如需获取hadoop-2.7.7安装包    
```
wget -O download/apache-flume-1.5.2-bin.tar.gz http://archive.apache.org/dist/flume/1.5.2/apache-flume-1.5.2-bin.tar.gz
```   
会下载 apache-flume-1.5.2-bin.tar.gz 安装包并存储在 download 文件夹下


