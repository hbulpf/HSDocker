# 构建 storm-1.1.0 镜像

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache  -t hs_storm:v1.0  .
```

## 2.获取 storm-1.1.0 安装包    
```
wget -O download/apache-storm-1.1.0.tar.gz https://archive.apache.org/dist/storm/apache-storm-1.1.0/apache-storm-1.1.0.tar.gz
```   
会下载 storm-1.1.0 安装包并存储在 download 文件夹下  

## 2.获取 zookeeper-3.4.10 安装包    
```
wget -O download/zookeeper-3.4.10.tar.gz https://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
```   
会下载 zookeeper-3.4.10 安装包并存储在 download 文件夹下  






