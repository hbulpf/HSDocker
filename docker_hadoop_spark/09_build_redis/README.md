**构建 hadoop-2.7.7 镜像**

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build -t hs_redis:v1.0 .
```

## 2. 如需获取redis安装包    
```
wget -O download/redis-4.0.13.tar.gz http://frp.hnbdata.cn:25081/common/hsdocker/redis-4.0.13.tar.gz
```   
会下载 apache-flume-1.5.2-bin.tar.gz 安装包并存储在 download 文件夹下


