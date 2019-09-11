**构建 redis-4.0.13 镜像**

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache -t hs_redis:v1.0 .
```

## 2. 如需获取redis安装包    
```
wget -O download/redis-4.0.13.tar.gz http://50125.hnbdata.cn:81/common/hsdocker/redis-4.0.13.tar.gz
```   
会下载 apache-flume-1.5.2-bin.tar.gz 安装包并存储在 download 文件夹下


