# 使用说明

**mirror文件夹存放spark-2.1.0安装包  
spark文件夹存放spark相关配置文件**  

### ！构建spark镜像前先确保构建好前一个hadoop镜像

## 1.拷贝整个目录
将整个目录包括spark,mirror文件夹及Dockerfile

## 2.获取spark2.1.0安装包    
```
wget -o mirror/spark-2.1.0-bin-without-hadoop.tgz https://archive.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-without-hadoop.tgz
```   
会下载spark安装包并存储在mirror文件夹下

## 3.构建镜像
在Dockerfile所在目录下:  
```
docker build -t <镜像名> .
```




