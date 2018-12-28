# 使用说明

**Hbase文件夹存放hbase安装包和相关配置文件**  

### ！构建hbase镜像前先确保构建好前一个spark镜像

## 1.拷贝整个目录
将整个目录包括Hbase文件夹及Dockerfile

## 2.获取hbase-1.2.6安装包    
```
wget -o Hbase/hbase-1.2.6-bin.tar.gz http://archive.apache.org/dist/hbase/1.2.6/hbase-1.2.6-bin.tar.gz
```   
会下载hbase安装包并存储在Hbase文件夹下

## 3.构建镜像
在Dockerfile所在目录下:  
```
docker build -t <镜像名> .
```




