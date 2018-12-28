# 使用方法

## 一. 测试环境 docker17.03

## 二. hadoop镜像
hadoop文件夹包含hadoop配置文件，安装包和镜像Dockerfile.

使用方法:  
```
#在Dockerfile所在目录  
docker build -t 镜像名 .
```

## 三. spark镜像
spark文件夹包含spark配置文件，安装包和镜像Dockerfile.
**构建基于前一个hadoop镜像**

使用方法:  
```
#在Dockerfile所在目录  
docker build -t 镜像名 .
```

## 四. hbase镜像
Hbase文件夹包含hbase配置文件，安装包和镜像Dockerfile.
**构建基于前一个spark镜像**

使用方法:  
```
#在Dockerfile所在目录  
docker build -t 镜像名 .
```


