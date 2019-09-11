# 实验十二  Hive实验：Hive分区

## 12.1 实验目的
掌握Hive分区的用法，加深对Hive分区概念的理解，了解Hive表在HDFS的存储目录结构。

## 12.2 实验要求
创建一个Hive分区表；根据数据年份创建 year=2014 和 year=2015 两个分区；将2015年的数据导入到 year=2015 的分区；在Hive界面用条件 year=2015 查询2015年的数据。

## 12.3 实验原理
分区(Partition)对应于数据库中的分区(Partition)列的密集索引，但是Hive中分区(Partition)的组织方式和数据库中的很不相同。在Hive中，**表中的一个分区(Partition)对应于表下的一个目录**，所有的分区(Partition)的数据都存储在对应的目录中。例如：pvs 表中包含 ds 和 ctry 两个分区(Partition)，则对应于 ds = 20090801, ctry = US的 HDFS 子目录为：/wh/pvs/ds=20090801/ctry=US；对应于 ds = 20090801, ctry = CA的HDFS子目录为；/wh/pvs/ds=20090801/ctry=CA。

外部表(External Table)指向已经在HDFS中存在的数据，可以创建分区(Partition)。它和Table在元数据的组织上是相同的，而实际数据的存储则有较大的差异。  

Table的创建过程和数据加载过程（这两个过程可以在同一个语句中完成），在加载数据的过程中，实际数据会被移动到数据仓库目录中；之后对数据的访问将会直接在数据仓库目录中完成。删除表时，表中的数据和元数据将会被同时删除。

## 12.4 实验步骤
因为Hive依赖于MapReduce，所以本实验之前**先要启动Hadoop集群**，然后再启动Hive进行实验。

### 12.4.1 建表
启动Hive后，查看Hive数据库，并选择default数据库：  
```
hive> show databases;
OK
default
Time taken: 0.717 seconds, Fetched: 1 row(s)
hive> use default;
OK
Time taken: 0.022 seconds
```

在命令端创建Hive分区表:  
```
hive> create table parthive(createdate string, value string) partitioned by(year string) row format delimited fields terminated by "\t";
OK
Time taken: 0.238 seconds
hive> show tables;
OK
parthive
Time taken: 0.018 seconds, Fetched: 1 row(s)
```

给parthive表创建两个分区:  
```
hive> alter table parthive add partition(year='2014');
OK
Time taken: 0.175 seconds
hive> alter table parthive add partition(year='2015');
OK
Time taken: 0.101 seconds
```

查看表结构：  
```
hive> describe parthive;
OK
createdate          	string              	                    
value               	string              	                    
year                	string              	                    
	 	 
# Partition Information	 	 
# col_name            	data_type           	comment             
	 	 
year                	string              	                    
Time taken: 0.067 seconds, Fetched: 8 row(s)
```

查看HDFS,对应分区目录已成功创建:
```
root@master:~# hadoop fs -ls /user/hive/warehouse/parthive
Found 2 items
drwxr-xr-x   - root supergroup      0 2018-07-10 11:23 /user/hive/warehouse/parthive/year=2014
drwxr-xr-x   - root supergroup      0 2018-07-10 11:23 /user/hive/warehouse/parthive/year=2015
```

### 12.4.2 创建本地数据并导入至year=2015分区
>如果是内嵌模式，之前创建的表如果quit退出，再次启动hive时表会消失，最好事先创建好输入数据

创建**parthive.txt**存储下列数据:(分隔符是\t)
```
2015-01-01  aaa 2015
2015-02-01  bbb 2015
2015-03-01  ccc 2015
2015-04-01  ddd 2015
2015-05-01  eee 2015
2015-06-01  fff 2015
2015-07-01  ggg 2015
```
上传数据到HDFS:`root@master:~# hadoop fs -put parthive.txt / `
导入数据:  
```
hive> load data inpath '/parthive.txt' into table parthive partition(year='2015');
Loading data to table default.parthive partition (year=2015)
Partition default.parthive{year=2015} stats: [numFiles=1, numRows=0, totalSize=140, rawDataSize=0]
OK
Time taken: 0.727 seconds
```

根据条件查询year=2015的数据:  
```
hive> select * from parthive t where t.year='2015';
OK
2015-01-01	aaa	2015
2015-02-01	bbb	2015
2015-03-01	ccc	2015
2015-04-01	ddd	2015
2015-05-01	eee	2015
2015-06-01	fff	2015
2015-07-01	ggg	2015
Time taken: 0.45 seconds, Fetched: 7 row(s)
```

```
hive> select count(*) from parthive where year='2015';
Query ID = root_20180710114705_a81599a0-80f8-49b5-938d-cae57d777650
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks determined at compile time: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1531206629291_0001, Tracking URL = http://master:8088/proxy/application_1531206629291_0001/
Kill Command = /usr/local/hadoop/bin/hadoop job  -kill job_1531206629291_0001
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2018-07-10 11:47:13,050 Stage-1 map = 0%,  reduce = 0%
2018-07-10 11:47:17,192 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 0.77 sec
2018-07-10 11:47:22,352 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 1.75 sec
MapReduce Total cumulative CPU time: 1 seconds 750 msec
Ended Job = job_1531206629291_0001
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 1.75 sec   HDFS Read: 7214 HDFS Write: 2 SUCCESS
Total MapReduce CPU Time Spent: 1 seconds 750 msec
OK
7
Time taken: 18.684 seconds, Fetched: 1 row(s)
```
输出表明Hive将处理过程翻译成了一个mapreduce任务，得出最终结果。