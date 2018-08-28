# 实验二十八 Pig版WordCount

## 28.1 实验目的  
掌握Pig的安装部署，了解Pig和MapReduce之间的关系，掌握Pig Latin编程语言，加深对Pig相关概念的理解。  

## 28.2 实验要求  
1.在集群中任一节点部署Pig（以下示例中选主节点）  
2.在Pig的Hadoop模式下统计任意一个HDFS文本中的单词出现次数，并将统计结果打印出来  
3.用Pig查询统计HDFS文件系统中结构化的数据  

## 28.3 实验原理  
**Pig是一种探索大规模数据集的脚本语言**。MapReducer的一个主要的缺点就是开发的周期太长了。我们要编写mapper和reducer，然后对代码进行编译打出jar包，提交到本地的JVM或者是hadoop的集群上，最后获取结果，这个周期是非常耗时的，即使使用Streaming(它是hadoop的一个工具，用来创建和运行一类特殊的map/reduce作业。所谓的特殊的map/reduce作业可以是可执行文件或脚本本件（python、PHP、c等）。Streaming使用“标准输入”和“标准输出”与我们编写的Map和Reduce进行数据的交换。由此可知，任何能够使用“标准输入”和“标准输出”的编程语言都可以用来编写MapReduce程序，能在这个过程中除去代码的编译和打包的步骤，但是这一个过程还是很耗时，Pig的强大之处就是他只要几行Pig Latin代码就能处理TB级别的数据。Pig提供了多个命令用于检查和处理程序中的数据结构，因此它能很好的支持我们写查询 。**Pig的一个很有用的特性就是它支持在输入数据中有代表性的一个小的数据集上试运行**。所以。我们在处理大的数据集前可以用那一个小的数据集检查 我们的程序是不是有错误的。  

Pig为大型的数据集的处理提供了更高层次的抽象。MapReducer能够让我们自己定义连续执行的map和reduce函数 ，但是数据处理往往需要很多的MapReducer过程才能实现，所以将数据处理要求改写成MapReducer模式是很复杂的。和MapReducer相比，Pig提供了更加丰富的数据结构 ，一般都是多值和嵌套的数据结构。Pig还提供了一套更强大的数据交换操作，包括了MapReducer中被忽视的"join"操作。  

Pig被设计为可以扩展的，处理路径上的每一个部分，载入，存储，过滤，分组，连接，都是可以定制的，这些操作都可以使用用户定义函数（user-defined function, UDF）进行修改 ，这些函数作用于Pig的嵌套数据模型。因此，它们可以在底层与Pig的操作集成，UDF的另外的一个好处是它们比MapReducer程序开发的库更易于重用。  

但是，Pig并不适合处理所有的“数据处理”任务。和MapReducer一样，它是为数据批处理而设计的，**如果想执行的查询只涉及一个大型数据集的一小部分数据，Pig的实现不是很好，因为它要扫描整个数据集或其中的很大一部分**。  

Pig Latin程序是由一系列的"操作"(operation)或"变换"(transformation)组成。每个操作或变换对输入进行数据处理，然后产生输出的结果。这些操作整体上描述了一个数据流，Pig执行的环境把数据流翻译为可执行的内部表示，并运行它。**在Pig的内部，这些变换和操作被转换成一系列的MapReducer**，但是我们一般情况下并不知道这些转换是怎么进行的，我们的主要的精力就花在数据上，而不是执行的细节上面。  

在有些情况下，Pig的表现不如MapReducer程序。总结为一句就是要么话花大量的时间来优化Java MapReducer程序，要么使用Pig Latin来编写查询确实能节约时间。  

## 28.4 实验步骤  

### 28.4.1 安装pig
pig的使用需要hadoop，这次镜像直接选择spark集成镜像,原实验里用的0.10版本的pig官网已不提供下载，这次实验选择最新的0.17版本。  
安装过程特别简单，下载后上传至master节点，解压至/usr/loca/pig目录, 添加环境变量  

vim /etc/profile,添加:  
```
export PIG_HOME=/usr/local/pig
export PATH=$PATH:$PIG_HOME/bin
```  
source /etc/profile 使生效  

在启动pig前，记得先启动好hadoop集群，**并进入hadoop的sbin目录下启动historyserver**:  
```
root@hadoop-master:/usr/local/hadoop/sbin# ./mr-jobhistory-daemon.sh start historyserver
chown: missing operand after '/usr/local/hadoop/logs'
Try 'chown --help' for more information.
starting historyserver, logging to /usr/local/hadoop/logs/mapred--historyserver-hadoop-master.out
root@hadoop-master:/usr/local/hadoop/sbin# jps
384 SecondaryNameNode
179 NameNode
1443 Jps
1397 JobHistoryServer
559 ResourceManager
```
通过jps命令可观察到启动了JobHistoryServer  

接着上传测试文件至HDFS，为接下来的pig操作作准备:  (创建pig目录,上传的是随意挑选的hadoop目录下的README.txt)
```
root@hadoop-master:/usr/local/hadoop# hadoop fs -mkdir /pig
root@hadoop-master:/usr/local/hadoop# ls
LICENSE.txt  NOTICE.txt  README.txt  bin  etc  include  lib  libexec  logs  sbin  share
root@hadoop-master:/usr/local/hadoop# hadoop fs -put README.txt /pig
root@hadoop-master:/usr/local/hadoop# hadoop fs -ls /pig            
Found 1 items
-rw-r--r--   2 root supergroup       1366 2018-08-07 07:35 /pig/README.txt
```  

上传完成后,直接输入pig命令即可进入交互:  
```
root@hadoop-master:/usr/local/hadoop/sbin# pig
18/08/07 07:38:52 INFO pig.ExecTypeProvider: Trying ExecType : LOCAL
18/08/07 07:38:52 INFO pig.ExecTypeProvider: Trying ExecType : MAPREDUCE
18/08/07 07:38:52 INFO pig.ExecTypeProvider: Picked MAPREDUCE as the ExecType
2018-08-07 07:38:52,151 [main] INFO  org.apache.pig.Main - Apache Pig version 0.17.0 (r1797386) compiled Jun 02 2017, 15:41:58
2018-08-07 07:38:52,151 [main] INFO  org.apache.pig.Main - Logging error messages to: /usr/local/hadoop/sbin/pig_1533627532150.log
2018-08-07 07:38:52,182 [main] INFO  org.apache.pig.impl.util.Utils - Default bootup file /root/.pigbootup not found
2018-08-07 07:38:52,653 [main] INFO  org.apache.hadoop.conf.Configuration.deprecation - mapred.job.tracker is deprecated. Instead, use mapreduce.jobtracker.address
2018-08-07 07:38:52,653 [main] INFO  org.apache.pig.backend.hadoop.executionengine.HExecutionEngine - Connecting to hadoop file system at: hdfs://hadoop-master:9000/
2018-08-07 07:38:53,091 [main] INFO  org.apache.pig.PigServer - Pig Script ID for the session: PIG-default-afc57ffa-d349-435c-8939-587686ea5648
2018-08-07 07:38:53,092 [main] WARN  org.apache.pig.PigServer - ATS is disabled since yarn.timeline-service.enabled set to false
grunt> 
```  
虽然在pig安装后没修改什么配置文件，但确实成功连上了hadoop集群。  

### 28.4.2 pig版wordCount  

键入wordCount代码:  
```
grunt> A = LOAD '/pig/README.txt' AS (line: chararray) ;
grunt> B = foreach A generate flatten(TOKENIZE(line,'\t ,.'))as word;
grunt> C = group B by word;  
grunt> D = foreach C generate group, COUNT(B) as count;
grunt> DUMP D;
```
接着pig会自动将其翻译为mapreduce任务并展示结果(以下为部分结果):  
```
(1,1)
(C,1)
(S,1)
(U,1)
(as,1)
(by,1)
(if,1)
(in,1)
(is,1)
(it,1)
(of,5)
(on,2)
(or,2)
(to,2)
(13),1)
(740,1)
(BIS,1)
(ENC,1)
(For,1)
(SSL,1)
(See,1)
(The,4)
(and,6)
(any,1)
(at:,2)
```  

### 28.4.3 结构化数据查询统计  
新建文本文件pigdata.txt添加以下内容:  
```
zhangsan,m,28
lisi,f,26
wangwu,m,20
```  
上传至HDFS的/pig目录:  
```
root@hadoop-master:~# vim pigdata.txt
root@hadoop-master:~# hadoop fs -put pigdata.txt /pig
root@hadoop-master:~# hadoop fs -ls /pig
Found 2 items
-rw-r--r--   2 root supergroup       1366 2018-08-07 07:35 /pig/README.txt
-rw-r--r--   2 root supergroup         36 2018-08-07 08:04 /pig/pigdata.txt
```  

进入pig并键入代码:  

**(1)按行读HDFS文件，并将数据按逗号分隔解析成姓名，性别，年龄**
```
grunt> A = LOAD '/pig/pigdata.txt' USING PigStorage(',') AS(name:chararray, sex:chararray, age:int);
grunt> DUMP A;
```

结果为:  
```
(zhangsan,m,28)
(lisi,f,26)
(wangwu,m,20)
```  

**(2)只查询name字段，并打印**:  
```
grunt> B = FOREACH A GENERATE name;
grunt> DUMP B;
```  

结果为:  
```
(zhangsan)
(lisi)
(wangwu)
```  

**(3)查询所有人员数据，并将年龄加一**:  
```
grunt> C = FOREACH A GENERATE name, sex, age+1;
grunt> DUMP C;
```  

结果为:  
```
(zhangsan,m,29)
(lisi,f,27)
(wangwu,m,21)
```  

**(4)查询年龄大于20的人员**:  
```
grunt> D = FILTER A BY (age > 20);
grunt> DUMP D;
```

结果为:  
```
(zhangsan,m,28)
(lisi,f,26)
```  

**(5)统计数据总条数**  
```
grunt> E = GROUP A ALL ;
grunt> F = FOREACH E GENERATE COUNT (A);
grunt> DUMP F;
```  

结果为:  
```
(3)
```  








