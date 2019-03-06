# 实验十七  Spark实验：Spark SQL

## 17.1 实验目的  
1．了解Spark SQL所能实现的功能；  
2．能够使用Spark SQL执行一些sql语句。

## 17.2 实验要求  
1．能在实验结束之后完成建立数据库，建立数据表的数据结构；  
2．建立数据表之后能在Spark SQL中执行SQL语句进行查询；  
3．练习怎么向Spark SQL中导入数据。

## 17.3 实验原理
Spark SQL用于以交互式方式编写并执行Spark SQL，且书写语法为类SQL，同Spark Shell一样，启动时写明 `--master spark://master:7077` 进入集群模式，否则默认进入单机模式。由于默认安装的Spark已经包含了Spark SQL，故无需安装其它组件，直接执行即可。  

Spark SQL使得运行SQL和HiveQL查询十分简单。Spark SQL能够轻易地定位相应的表和元数据。Spark SQL为Spark提供了查询结构化数据的能力，查询时既可以使用SQL也可以使用人们熟知的DataFrame API（RDD）。Spark SQL支持多语言编程包括Java、Scala、Python及R，开发人员可以根据自身喜好进行选择。  

**DataFrame**是Spark SQL的核心，它将数据保存为行构成的集合，行对应列有相应的列名。使用DataFrames可以非常方便地查询数据、给数据绘图及进行数据过滤。  

DataFrames也可以用于数据的输入与输出，例如利用Spark SQL中的DataFrames，可以轻易地将下列数据格式加载为表并进行相应的查询操作：  
1．RDD；  
2．JSON；  
3．Hive；  
4．Parquet；  
5．MySQL；  
6．HDFS；  
7．S3；  
8．JDBC；  
9．其它。  

数据一旦被读取，借助于DataFrames便可以很方便地进行数据过滤、列查询、计数、求平均值及将不同数据源的数据进行整合。如果你正计划通过读取和写数据来进行分析，Spark SQL可以轻易地帮你实现并将整个过程自动化。  

## 17.4 实验步骤

### 17.4.1 创建数据文件weather.dat:  
```
1   nanjing 16.5
2   shanghai    20.1
3   beijing 12.4
4   zhengzhou   8.3
5   hainan  23.3
6   fujian  24.1
7   hefei   18
```
文件的路径为: /root/weather.dat  

### 17.4.2 启动Spark SQL
```
root@master:~# spark-sql --master spark://master:7077

后面会出现一大串的信息

spark-sql> 

说明成功启动
```

### 17.4.3 执行操作  
确认当前Spark SQL中是否已经存在我们需要建立的数据库:  
```
spark-sql> show databases;

省略一堆无关信息，显示结果:
default
Time taken: 4.948 seconds, Fetched 1 row(s)
18/07/20 03:37:08 INFO CliDriver: Time taken: 4.948 seconds, Fetched 1 row(s)
```

创建数据库db:  
```
spark-sql> create database db;

Time taken: 0.948 seconds
18/07/20 03:42:43 INFO CliDriver: Time taken: 0.948 seconds
```  

切换当前数据库:  
```
spark-sql> use db;

Time taken: 0.057 seconds
18/07/20 03:43:38 INFO CliDriver: Time taken: 0.057 seconds
```

建表:  
```
spark-sql> create table weather(id int, city string, temperature double) row format delimited fields terminated by "\t";

Time taken: 1.035 seconds
18/07/20 03:45:00 INFO CliDriver: Time taken: 1.035 seconds
```

检查表是否成功创建:  
```
spark-sql> show tables;

db	weather	false
Time taken: 0.463 seconds, Fetched 1 row(s)
18/07/20 03:46:06 INFO CliDriver: Time taken: 0.463 seconds, Fetched 1 row(s)
```  

导入数据weather.dat:  
```
spark-sql> load data local inpath '/root/weather.dat' overwrite into table weather;

Time taken: 0.198 seconds
18/07/20 07:36:04 INFO CliDriver: Time taken: 0.198 seconds
```

查询数据：(集群模式下启动，前面的操作都正常，到查询数据这里就会报错说文件无法找到，切换成单机模式又能正常操作，原因还不清楚)。
```
spark-sql> select * from weather;

1	nanjing	16.5
2	shanghai	20.1
3	beijing	12.4
4	zhengzhou	8.3
5	hainan	23.3
6	fujian	24.1
7	hefei	18.0
Time taken: 0.424 seconds, Fetched 7 row(s)
18/07/20 07:36:09 INFO CliDriver: Time taken: 0.424 seconds, Fetched 7 row(s)
```

```
spark-sql> select * from weather where temperature > 10.0;

1	nanjing	16.5
2	shanghai	20.1
3	beijing	12.4
5	hainan	23.3
6	fujian	24.1
7	hefei	18.0
Time taken: 3.016 seconds, Fetched 6 row(s)
18/07/20 07:38:08 INFO CliDriver: Time taken: 3.016 seconds, Fetched 6 row(s)
```

删除表:``drop table weather;``