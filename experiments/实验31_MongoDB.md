# 实验三十一 MongoDB实验：读写MongoDB  

## 31.1 实验目的  
1.了解NoSQL数据库的原理；  
2.理解NoSQL数据库的结构；  
3.比较MongoDB和Hbase的区别；  
4.能对MongoDB的存储格式有一定的了解；  
5.能正确的使用MongoDB并能进行简单使用。  

## 31.2 实验要求  
1.正确的搭建MongoDB数据库环境；  
2.能正常启动MongoDB的服务和服务的连接；  
3.能在MongoDB的的shell中进行一些简单的使用。  

## 31.3 实验原理  
**MongoDB是一个基于分布式文件存储的数据库**。由C++语言编写。旨在为WEB应用提供可扩展的高性能数据存储解决方案。  

特点：高性能、易部署、易使用，存储数据非常方便。  
主要功能特性有：  
1.面向集合存储，易存储对象类型的数据；  
2.模式自由；  
3.支持动态查询；  
4.支持完全索引，包含内部对象；  
5.支持查询；  
6.支持复制和故障恢复；  
7.使用高效的二进制数据存储，包括大型对象（如视频等）；  
8.自动处理碎片，以支持云计算层次的扩展性；  
9.支持Ruby，Python，Java，C++，PHP等多种语言；  
10.文件存储格式为BSON（一种JSON的扩展）；  
11.可通过网络访问。  

**所谓“面向集合”（Collenction-Oriented），意思是数据被分组存储在数据集中，被称为一个集合（Collenction)。每个集合在数据库中都有一个唯一的标识名，并且可以包含无限数目的文档**。集合的概念类似关系型数据库（RDBMS）里的表（table），不同的是它不需要定义任何模式（schema)。  

模式自由（schema-free)，意味着对于存储在mongodb数据库中的文件，我们不需要知道它的任何结构定义。如果需要的话，你完全可以把不同结构的文件存储在同一个数据库里。  

**存储在集合中的文档，被存储为键-值对的形式。键用于唯一标识一个文档，为字符串类型，而值则可以是各种复杂的文件类型。我们称这种存储形式为BSON（Binary JSON）。**  

## 31.4 实验步骤  
本实验总体分为几个步骤:  
1.安装MongoDB；  
2.启动MongoDB服务；  
3.连接MongoDB服务；  
4.启动MongoDB的shell，执行一些简单命令。  

### 31.4.1 安装MongoDB  
[下载链接](https://www.mongodb.com/download-center?jmp=nav#production)  
选择对应的系统版本进行下载，这里下载的是ubuntu14.04的版本。   

下载后解压至/usr/local/mongodb目录下:  
```
root@hadoop-master:~# tar -zxvf mongodb-linux-x86_64-ubuntu1404-4.0.1.tgz  
root@hadoop-master:~# mv mongodb-linux-x86_64-ubuntu1404-4.0.1 /usr/local/mongodb
```  

### 31.4.2 启动MongoDB  
首先在MongoDB的安装目录下建立一个数据目录 
```
root@hadoop-master:/usr/local/mongodb# mkdir data
```

在**启动前需要安装openssl**， 否则之后无法正常启动:  
```
root@hadoop-master:~# sudo apt-get install libcurl3 openssl
```  

启动mongodb:  
```
root@hadoop-master:/usr/local/mongodb# bin/mongod --dbpath ./data &
[1] 304
```  

### 31.4.3 连接使用MongoDB  
```
root@hadoop-master:/usr/local/mongodb# bin/mongo
```  
之后会输出一大串并进入shell  

### 31.4.4 连接启动MongoDB的shell，执行一些简单命令  
连接到MongoDB之后，进入shell环境之后执行如下的简单操作，以此来熟悉MongoDB的操作。  

#### 31.4.4.1 创建一个Collection  
```
> db.createCollection("weather");
2018-08-13T02:30:24.418+0000 I STORAGE  [conn1] createCollection: test.weather with generated UUID: dcec9972-a8b6-4e6b-b1c6-14b2aef33589
2018-08-13T02:30:24.606+0000 I COMMAND  [conn1] command test.weather appName: "MongoDB Shell" command: create { create: "weather", lsid: { id: UUID("4ffe8375-d42e-436c-8d15-6badea56ceaf") }, $db: "test" } numYields:0 reslen:38 locks:{ Global: { acquireCount: { r: 1, w: 1 } }, Database: { acquireCount: { W: 1 } } } protocol:op_msg 188ms
{ "ok" : 1 }
```  

#### 31.4.4.2 插入单条数据  
```
> db.weather.save({temp:31,location:"nanjing"});
WriteResult({ "nInserted" : 1 })
```  

#### 31.4.4.3 插入多条数据  
```
> for(var i = 0;i < 30;i++) { db.weather.save({tep:i,location:"nanjing"}) };
WriteResult({ "nInserted" : 1 })
```  

#### 31.4.4.4 简单遍历  
```
> db.weather.find();
{ "_id" : ObjectId("5b70ed5c09f0cd4632bc277e"), "temp" : 31, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc277f"), "tep" : 0, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2780"), "tep" : 1, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2781"), "tep" : 2, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2782"), "tep" : 3, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2783"), "tep" : 4, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2784"), "tep" : 5, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2785"), "tep" : 6, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2786"), "tep" : 7, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2787"), "tep" : 8, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2788"), "tep" : 9, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2789"), "tep" : 10, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278a"), "tep" : 11, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278b"), "tep" : 12, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278c"), "tep" : 13, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278d"), "tep" : 14, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278e"), "tep" : 15, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278f"), "tep" : 16, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2790"), "tep" : 17, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2791"), "tep" : 18, "location" : "nanjing" }
Type "it" for more
> it
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2792"), "tep" : 19, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2793"), "tep" : 20, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2794"), "tep" : 21, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2795"), "tep" : 22, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2796"), "tep" : 23, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2797"), "tep" : 24, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2798"), "tep" : 25, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2799"), "tep" : 26, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc279a"), "tep" : 27, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc279b"), "tep" : 28, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc279c"), "tep" : 29, "location" : "nanjing" }
```  

#### 31.4.4.5 复杂遍历  
以下只是遍历的部分数据
```
> var c=db.weather.find();
> while(c.hasNext()){printjson(c.next())};
{
	"_id" : ObjectId("5b70ed5c09f0cd4632bc277e"),
	"temp" : 31,
	"location" : "nanjing"
}
{
	"_id" : ObjectId("5b70ed6709f0cd4632bc277f"),
	"tep" : 0,
	"location" : "nanjing"
}
{
	"_id" : ObjectId("5b70ed6709f0cd4632bc2780"),
	"tep" : 1,
	"location" : "nanjing"
}
{
	"_id" : ObjectId("5b70ed6709f0cd4632bc2781"),
	"tep" : 2,
	"location" : "nanjing"
}
{
	"_id" : ObjectId("5b70ed6709f0cd4632bc2782"),
	"tep" : 3,
	"location" : "nanjing"
}
{
	"_id" : ObjectId("5b70ed6709f0cd4632bc2783"),
	"tep" : 4,
	"location" : "nanjing"
}
```  

#### 31.4.4.6 查找数据  
```
> db.weather.find({location:"nanjing"})
{ "_id" : ObjectId("5b70ed5c09f0cd4632bc277e"), "temp" : 31, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc277f"), "tep" : 0, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2780"), "tep" : 1, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2781"), "tep" : 2, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2782"), "tep" : 3, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2783"), "tep" : 4, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2784"), "tep" : 5, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2785"), "tep" : 6, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2786"), "tep" : 7, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2787"), "tep" : 8, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2788"), "tep" : 9, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2789"), "tep" : 10, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278a"), "tep" : 11, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278b"), "tep" : 12, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278c"), "tep" : 13, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278d"), "tep" : 14, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278e"), "tep" : 15, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278f"), "tep" : 16, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2790"), "tep" : 17, "location" : "nanjing" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2791"), "tep" : 18, "location" : "nanjing" }
Type "it" for more
```  

#### 31.4.4.7 更新数据  
```
> db.weather.update({location:"nanjing"},{$set:{location:"shanghai"}},false,true);
WriteResult({ "nMatched" : 31, "nUpserted" : 0, "nModified" : 31 })
> db.weather.find();
{ "_id" : ObjectId("5b70ed5c09f0cd4632bc277e"), "temp" : 31, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc277f"), "tep" : 0, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2780"), "tep" : 1, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2781"), "tep" : 2, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2782"), "tep" : 3, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2783"), "tep" : 4, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2784"), "tep" : 5, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2785"), "tep" : 6, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2786"), "tep" : 7, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2787"), "tep" : 8, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2788"), "tep" : 9, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2789"), "tep" : 10, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278a"), "tep" : 11, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278b"), "tep" : 12, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278c"), "tep" : 13, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278d"), "tep" : 14, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278e"), "tep" : 15, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc278f"), "tep" : 16, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2790"), "tep" : 17, "location" : "shanghai" }
{ "_id" : ObjectId("5b70ed6709f0cd4632bc2791"), "tep" : 18, "location" : "shanghai" }
Type "it" for more
```  

#### 31.4.4.8 删除数据  
```
> db.weather.remove({location:"shanghai"})
WriteResult({ "nRemoved" : 31 })
> db.weather.find();
> 
```  
删除了shanghai的所有数据，查询无法再获得数据  

#### 31.4.4.9 删除Collection  
```
> db.weather.drop();
2018-08-13T02:48:32.107+0000 I COMMAND  [conn1] `: drop test.weather
2018-08-13T02:48:32.108+0000 I STORAGE  [conn1] Finishing collection drop for test.weather (dcec9972-a8b6-4e6b-b1c6-14b2aef33589).
true
```





