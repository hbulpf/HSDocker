# 使用方法

## 一. 制作hadoop镜像
hadoop文件夹包含hadoop配置文件，安装包和镜像Dockerfile.

使用方法:  
```
#在Dockerfile所在目录  
docker build -t hs_hadoop:v1.0 .
```

## 二. 制作spark镜像
spark文件夹包含spark配置文件，安装包和镜像Dockerfile.
**构建基于前一个hadoop镜像**

使用方法:  
```
#在Dockerfile所在目录  
docker build -t hs_spark:v1.0 .
```

## 三. 制作hbase镜像
Hbase文件夹包含hbase配置文件，安装包和镜像Dockerfile.
**构建基于前一个spark镜像**

使用方法:  
```
#在Dockerfile所在目录  
docker build -t hs_hbase:v1.0 .
```

## 四. 制作hive镜像
hive文件夹包含hive配置文件，安装包和镜像Dockerfile.
**构建基于前一个hbase镜像**

使用方法:  
```
#在Dockerfile所在目录  
docker build -t hs_hive:v1.0  .
```


