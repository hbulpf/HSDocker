**构建 hadoop-2.7.7 镜像**

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache -t hs_hadoop:v1.0 .
```

## 2. 如需获取hadoop-2.7.7安装包    
```
wget -O download/hadoop-2.7.7.tar.gz http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
```   
会下载 hadoop-2.7.7 安装包并存储在 download 文件夹下


