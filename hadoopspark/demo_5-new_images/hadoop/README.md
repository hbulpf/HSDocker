# 使用说明

**mirror文件夹存放hadoop-2.7.2安装包
hadoop文件夹存放hadoop相关配置文件**

## 1.拷贝整个目录
将整个目录包括hadoop,mirror文件夹及Dockerfile

## 2.获取hadoop-2.7.7安装包    
```
wget -o mirror/hadoop-2.7.7.tar.gz http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
```   
会下载hadoop安装包并存储在mirror文件夹下

## 3.构建镜像
在Dockerfile所在目录下:  
```
docker build -t <镜像名> .
```




