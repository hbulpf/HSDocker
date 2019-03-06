**构建 hbase-1.2.6 镜像**

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build -t hs_hbase:v1.0 .
```

## 2. 如需获取 hbase-1.2.6 安装包        
```
wget -O download/hbase-1.2.6-bin.tar.gz http://archive.apache.org/dist/hbase/1.2.6/hbase-1.2.6-bin.tar.gz
```   
会下载 hive-1.2.2 安装包并存储在 download 文件夹下
