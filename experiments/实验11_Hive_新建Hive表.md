# 实验十一 Hive实验：新建Hive表
## 11.1 实验目的
1. 学会创建Hive的表；  
2. 显示Hive中的所有表；  
3. 显示Hive中表的列项；  
4. 修改Hive中的表并能够删除Hive中的表。

## 11.2 实验要求
1. 要求实验结束时；  
2. 每位学生均能够完成Hive的DDL操作；  
3. 能够在Hive中新建，显示，修改和删除表等功能。

## 11.3 实验原理
Hive没有专门的数据存储格式，也没有为数据建立索引，用户可以非常自由的组织Hive中的表，只需要在创建表的时候告诉Hive数据中的列分隔符和行分隔符，Hive就可以解析数据。  

Hive中所有的数据都存储在HDFS中，Hive中包含以下数据模型：**表(Table)，外部表(External Table)，分区(Partition)，桶(Bucket)**。  

Hive中Table和数据库中Table在概念上是类似的，**每一个Table在Hive中都有一个相应的目录存储数据**。例如，一个表pvs，它在HDFS 中的路径为：/wh/pvs，其中，wh是在 hive-site.xml 中由 `${hive.metastore.warehouse.dir}` 指定的数据仓库的目录，所有的Table数据（不包括External Table)都保存在这个目录中。

## 11.4 实验步骤

### 11.4.1 启动hive
```
root@master:/usr/local/hive/conf# hive

Logging initialized using configuration in jar:file:/usr/local/hive/lib/hive-common-1.2.2.jar!/hive-log4j.properties
hive> 
```

### 11.4.2 创建表
默认情况下，新建表的存储格式均为Text类型，字段间默认分隔符为键盘上的Tab键。  
创建一个有两个字段的**pokes表**，其中第一列名为foo，数据类型为INT，第二列名为bar，类型为STRING：
```
hive> CREATE TABLE pokes(foo INT, bar STRING);
OK
Time taken: 1.096 seconds
```

创建一个有两个实体列和一个（虚拟）分区字段的 invites 表：  
```
hive> CREATE TABLE invites(foo INT, bar STRING) PARTITIONED BY(ds STRING);
OK
Time taken: 0.113 seconds
```  
注意：分区字段并不属于invites，当向invites导入数据时，ds字段会用来过滤导入的数据。

### 11.4.3 显示表
显示所有的表:  
```
hive> show tables;
OK
invites
pokes
Time taken: 0.085 seconds, Fetched: 2 row(s)
```
显示表（正则查询），同MySQL中操作一样，Hive也支持正则查询，比如显示以.s结尾的表:  
```
hive> show tables '.*s';
OK
invites
pokes
Time taken: 0.033 seconds, Fetched: 2 row(s)
```

### 11.4.4 显示表列
```
hive> describe invites;
OK
foo                 	int                 	                    
bar                 	string              	                    
ds                  	string              	                    
	 	 
# Partition Information	 	 
# col_name            	data_type           	comment             
	 	 
ds                  	string              	                    
Time taken: 0.195 seconds, Fetched: 8 row(s)
```

### 11.4.5 更改表
修改表 events 名为 3koobecaf (自行创建任意类型events表)：
```
hive> create table events(foo int, bar int);
OK
Time taken: 0.076 seconds
hive> alter table events rename to 3koobecaf;
OK
Time taken: 0.215 seconds
hive> show tables;
OK
3koobecaf
invites
pokes
Time taken: 0.018 seconds, Fetched: 3 row(s)
```

将 pokes 表新增一列(列名为new_col,类型为int):
```
hive> alter table pokes add columns(new_col int);
OK
Time taken: 0.112 seconds
hive> describe pokes;
OK
foo                 	int                 	                    
bar                 	string              	                    
new_col             	int                 	                    
Time taken: 0.064 seconds, Fetched: 3 row(s)
```

将 invites 表新增一列（列名为new_col2，类型为INT），同时增加注释“a comment”：  
```
hive> alter table invites add columns(new_col2 int comment 'a comment');
OK
Time taken: 0.095 seconds
hive> describe invites;
OK
foo                 	int                 	                    
bar                 	string              	                    
new_col2            	int                 	a comment           
ds                  	string              	                    
	 	 
# Partition Information	 	 
# col_name            	data_type           	comment             
	 	 
ds                  	string              	                    
Time taken: 0.068 seconds, Fetched: 9 row(s)
```

替换 invites 表所有列名（数据不动):  
```
hive> alter table invites replace columns(foo int, bar string, baz int comment 'baz replaces new_col2');
OK
Time taken: 0.105 seconds
hive> describe invites;
OK
foo                 	int                 	                    
bar                 	string              	                    
baz                 	int                 	baz replaces new_col2
ds                  	string              	                    
	 	 
# Partition Information	 	 
# col_name            	data_type           	comment             
	 	 
ds                  	string              	                    
Time taken: 0.057 seconds, Fetched: 9 row(s)
```
可以看到 new_col2 被替换成了 baz


### 11.4.6 删除表（或列）
删除 invites 表 bar 和 baz 两列：
```
hive> alter table invites replace columns(foo int comment'only keep the first column');
OK
Time taken: 0.08 seconds
hive> describe invites;
OK
foo                 	int                 	only keep the first column
ds                  	string              	                    
	 	 
# Partition Information	 	 
# col_name            	data_type           	comment             
	 	 
ds                  	string              	                    
Time taken: 0.058 seconds, Fetched: 7 row(s)
```

删除pokes表：
```
hive> drop table pokes;
OK
Time taken: 4.041 seconds
hive> show tables;
OK
events
invites
Time taken: 0.026 seconds, Fetched: 2 row(s)
```




