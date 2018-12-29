# 使用说明

**hive文件夹存放hive安装包和相关配置文件**  

### ！构建hive镜像前先确保构建好前一个hbase镜像

## 1.拷贝整个目录
将整个目录包括hive文件夹及Dockerfile

## 2.获取hbase-1.2.6安装包    
```
wget -o hive/apache-hive-1.2.2-bin.tar.gz https://www-eu.apache.org/dist/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz
```   
会下载hive安装包并存储在hive文件夹下

## 3.构建镜像
在Dockerfile所在目录下:  
```
docker build -t <镜像名> .
```




