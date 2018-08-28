#  实验十 Hive实验：部署Hive

## 10.1 实验目的
1.理解Hive存在的原因；  
2.理解Hive的工作原理；  
3.理解Hive的体系架构；  
4.并学会如何进行内嵌模式部署；  
5.启动Hive，然后将元数据存储在HDFS上。

## 10.2 实验要求
1.完成Hive的内嵌模式部署；  
2.能够将Hive数据存储在HDFS上；  
3.待Hive环境搭建好后，能够启动并执行一般命令。

## 10.3 实验原理
Hive是Hadoop 大数据生态圈中的**数据仓库**，其提供以表格的方式来组织与管理HDFS上的数据、以**类SQL**的方式来操作表格里的数据，Hive的设计目的是能够**以类SQL的方式查询存放在HDFS上的大规模数据集**，不必开发专门的MapReduce应用。  

Hive本质上相当于一个MapReduce和HDFS的翻译终端，用户提交Hive脚本后，Hive运行时环境会将这些脚本翻译成MapReduce和HDFS操作并向集群提交这些操作。  

当用户向Hive提交其编写的HiveQL后，首先，Hive运行时环境会将这些脚本翻译成MapReduce和HDFS操作，紧接着，Hive运行时环境使用Hadoop命令行接口向Hadoop集群提交这些MapReduce和HDFS操作，最后，Hadoop集群逐步执行这些MapReduce和HDFS操作，整个过程可概括如下：  
（1）用户编写HiveQL并向Hive运行时环境提交该HiveQL。  
（2）Hive运行时环境将该HiveQL翻译成MapReduce和HDFS操作。  
（3）Hive运行时环境调用Hadoop命令行接口或程序接口，向Hadoop集群提交翻译后的HiveQL。  
（4）Hadoop集群执行HiveQL翻译后的MapReduce-APP或HDFS-APP。  

由上述执行过程可知，Hive的核心是其运行时环境，该环境能够将类SQL语句编译成MapReduce。  

Hive构建在基于静态批处理的Hadoop之上，Hadoop通常都有较高的延迟并且在作业提交和调度的时候需要大量的开销。因此，Hive并不能够在大规模数据集上实现低延迟快速的查询，例如，Hive在几百MB的数据集上执行查询一般有分钟级的时间延迟。因此，**Hive并不适合那些需要低延迟的应用**，例如，联机事务处理（OLTP）。Hive查询操作过程严格遵守Hadoop MapReduce的作业执行模型，Hive将用户的HiveQL 语句通过解释器转换为MapReduce作业提交到Hadoop集群上，Hadoop监控作业执行过程，然后返回作业执行结果给用户。Hive并非为联机事务处理而设计，Hive并不提供实时的查询和基于行级的数据更新操作。**Hive的最佳使用场合是大数据集的批处理作业**，例如，网络日志分析。  

Hive架构与基本组成如图10-1所示：  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex10/1.jpg)

## 10.4 实验步骤
相对于其他组件，Hive部署要复杂得多，按metastore存储位置的不同，其部署模式分为**内嵌模式**、**本地模式**和**完全远程模式**三种。当使用完全模式时，可以**提供很多用户同时访问并操作Hive**，并且此模式还提供各类接口（BeeLine，CLI，甚至是Pig），这里我们以内嵌模式为例。

**内嵌模式**：hive服务和metastore服务运行在同一个进程中，derby服务也运行在该进程中。  
**本地模式**：hive服务和metastore服务运行在同一个进程中，mysql是单独的进程，可以在同一台机器上，也可以在远程机器上。该模式只需将hive-site.xml中的ConnectionURL指向mysql，并配置好驱动名、数据库连接账号即可。  
**远程模式**：hive服务和metastore在不同的进程内，可能是不同的机器，连接远程的mysql并不能称之为“远程模式”，是否远程指的是metastore和hive服务是否在同一进程内，换句话说，“远”指的是metastore和hive服务离得“远”。

### 10.4.1 下载hive并解压:
``wget http://mirrors.hust.edu.cn/apache/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz``

```
root@hadoop-master:~# wget http://mirrors.hust.edu.cn/apache/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz
root@hadoop-master:~# tar -xzvf apache-hive-1.2.2-bin.tar.gz 
root@hadoop-master:~# ls
apache-hive-1.2.2-bin         hdfs              start-hadoop.sh
apache-hive-1.2.2-bin.tar.gz  run-wordcount.sh
root@hadoop-master:~# mv apache-hive-1.2.2-bin /usr/local/hive
```

### 10.4.2 设定HIVE_HOME环境变量,修改/etc/profile:  
```
export HIVE_HOME=/usr/local/hive
export PATH=$PATH:$HIVE_HOME/bin
```
``source /etc/profile``使修改生效

### 10.4.3 修改Hive配置文件:  
切换到**HIVE_HOME/conf**目录下，执行以下命令：
```
root@hadoop-master:/usr/local/hive/conf# cp hive-env.sh.template hive-env.sh 
root@hadoop-master:/usr/local/hive/conf# vi hive-env.sh
```

在hive-env.sh中找到对应位置添加以下内容:
```
# HADOOP_HOME=/usr/local/hadoop
# export HIVE_CONF_DIR=/usr/local/hive/conf
# export HIVE_AUX_JARS_PATH=/usr/local/hive/lib
```

### 10.4.5 启动Hive
直接输入命令hive即可启动:
```
root@hadoop-master:/usr/local/hive/conf# hive

Logging initialized using configuration in jar:file:/usr/local/hive/lib/hive-common-1.2.2.jar!/hive-log4j.properties
hive> 
```

## 10.5 实验结果
Hive的一些基本命令:  
```
root@hadoop-master:/usr/local/hive/conf# hive

Logging initialized using configuration in jar:file:/usr/local/hive/lib/hive-common-1.2.2.jar!/hive-log4j.properties
hive> show databases;
OK
default
Time taken: 0.729 seconds, Fetched: 1 row(s)
hive> show functions;
OK
!
!=
%
&
*
+
-
/
<
Time taken: 0.014 seconds, Fetched: 216 row(s)
hive> quit;
root@hadoop-master:/usr/local/hive/conf# 
```

命令末尾带**";"**,退出是**quit;**


