# 使用说明

## 1.拷贝整个目录
将整个目录包括hadoop,mirror文件夹及[Dockerfile](./Dockerfile)

## 2.获取hadoop-2.7.7安装包    
```
wget -O download/hadoop-2.7.7.tar.gz http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
```   
会下载hadoop安装包并存储在mirror文件夹下

## 3.构建镜像
在[Dockerfile](./Dockerfile)所在目录下:  
```
docker build -t <镜像名> .
```




