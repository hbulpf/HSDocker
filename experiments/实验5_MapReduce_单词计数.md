# 实验五  MapReduce实验：单词计数

## 5.1 实验目的
基于MapReduce思想，编写WordCount程序。

## 5.2 实验要求  
1． 理解 MapReduce 编程思想；  
2． 会编写 MapReduce 版本WordCount；  
3． 会执行该程序；  
4． 自行分析执行过程。

## 5.3 实验原理
MapReduce是一种计算模型，简单的说就是**将大批量的工作(数据)分解(Map)执行，然后再将结果合并成最终结果(Reduce)**。这样做的好处是可以在任务被分解后通过大量机器进行并行计算，减少整个操作的时间。

**适用范围**：数据量大，但是数据种类小可以放入内存。

**基本原理及要点**：将数据交给不同的机器去处理，数据划分，结果归约。

**理解MapReduce和Yarn**：在新版Hadoop中，Yarn作为一个资源管理调度框架，是Hadoop下MapReduce程序运行的生存环境。其实MapRuduce除了可以运行在Yarn框架下，也可以运行在诸如Mesos，Corona之类的调度框架上，使用不同的调度框架，需要针对Hadoop做不同的适配。

一个完整的MapReduce程序在Yarn中执行过程如下：  
(1) ResourcManager JobClient 向 ResourcManager 提交一个job。  
(2) ResourcManager 向 Scheduler 请求一个供 MRAppMaster 运行的 container，然后启动它。  
(3) MRAppMaster 启动起来后向 ResourcManager注册。  
(4) ResourcManagerJobClient 向 ResourcManager 获取到 MRAppMaster 相关的信息，然后直接与 MRAppMaster 进行通信。  
(5) MRAppMaster 算 splits 并为所有的 map 构造资源请求。  
(6) MRAppMaster 做一些必要的 MR OutputCommitter 的准备工作。  
(7) MRAppMaster 向 RM(Scheduler) 发起资源请求，得到一组供 map/reduce task 运行的 container，然后与 NodeManager 一起对每一个 container 执行一些必要的任务，包括资源本地化等。  
(8) MRAppMaster 监视运行着的 task 直到完成，当 task 失败时，申请新的 container 运行失败的 task。  
(9) 当每个 map/reduce task 完成后，MRAppMaster 运行 MROutputCommitter 的 cleanup 代码，也就是进行一些收尾工作。  
(10) 当所有的 map/reduce s完成后，MRAppMaster 运行 OutputCommitter 的必要的 job commit 或者 abort APIs 。  
(11) MRAppMaster退出。

### 5.3.1 MapReduce编程
编写在 Hadoop 中依赖 Yarn 框架执行的 MapReduce 程序，并不需要自己开发 MRAppMaster 和 YARNRunner ，因为 Hadoop 已经默认提供通用的 YARNRunner 和 MRAppMaster 程序，大部分情况下只需要编写相应的 Map 处理和 Reduce 处理过程的业务程序即可。

编写一个MapReduce程序并不复杂，主要将计算过程分为以下五个步骤：  
(1) 迭代。遍历输入数据，并将之解析成 key/value 对。  
(2) 将输入 key/value 对映射(map)成另外一些 key/value 对。  
(3) 依据 key 对中间数据进行分组(grouping)。  
(4) 以组为单位对数据进行归约(reduce)。  
(5) 迭代。将最终产生的key/value对保存到输出文件中。

### 5.3.2 Java API解析
(1) InputFormat：用于描述输入数据的格式，常用的为 TextInputFormat 提供如下两个功能：
```
    1. 数据切分: 按照某个策略将输入数据切分成若干个split，以便确定 Map Task 个数以及对应的split。
    2. 为 Mapper 提供数据: 给定某个split，能将其解析成一个个 key/value 对。
```  
(2) OutputFormat：用于描述输出数据的格式，它能够将用户提供的 key/value 对写入特定格式的文件中。  
(3) Mapper/Reducer: Mapper/Reducer中封装了应用程序的数据处理逻辑。  
(4) Writable: Hadoop自定义的序列化接口。实现该类的接口可以用作 MapReduce 过程中的 value 数据使用。  
(5) WritableComparable：在Writable基础上继承了Comparable 接口，实现该类的接口可以用作MapReduce过程中的key数据使用。(因为key包含了比较排序的操作)。

## 5.4 实验步骤
本实验主要分为，确认前期准备，编写MapReduce程序，打包提交代码。查看运行结果这几个步骤，详细如下：

### 5.4.1 启动Hadoop
启动Hadoop集群后检查服务是否启动

```
root@master:~# jps
374 SecondaryNameNode
173 NameNode
543 ResourceManager
808 Jps
```
成功启动

### 5.4.2  上传数据文件到HDFS
上传WordCount的测试文件
```
root@master:/# cd /usr/local/hadoop
root@master:/usr/local/hadoop# ls
LICENSE.txt  README.txt  etc      lib      logs  share
NOTICE.txt   bin         include  libexec  sbin
```
不妨就上传README.txt
```
root@master:/usr/local/hadoop# hadoop fs -put README.txt /
root@master:/usr/local/hadoop# hadoop fs -ls /
Found 1 items
-rw-r--r--   2 root supergroup       1366 2018-06-30 07:57 /README.txt
```

### 5.4.3 编写MapReduce程序
主要编写Map和Reduce类，其中Map过程需要继承 `org.apache.hadoop.mapreduce` 包中 `Mapper` 类，并重写其 map 方法；Reduce过程需要继承 `org.apache.hadoop.mapreduce` 包中 `Reduce` 类，并重写其 reduce 方法
```java
import java.io.IOException;
import java.util.StringTokenizer;
 
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;
 
public class WordCount {
 
  public static class TokenizerMapper 
       extends Mapper<Object, Text, Text, IntWritable>{
 
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();
 
    public void map(Object key, Text value, Context context
                    ) throws IOException, InterruptedException {
      StringTokenizer itr = new StringTokenizer(value.toString());
      while (itr.hasMoreTokens()) {
        word.set(itr.nextToken());
        context.write(word, one);
      }
    }
  }
 
  public static class IntSumReducer 
       extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();
 
    public void reduce(Text key, Iterable<IntWritable> values, 
                       Context context
                       ) throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      result.set(sum);
      context.write(key, result);
    }
  }
 
  public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
    if (otherArgs.length != 2) {
      System.err.println("Usage: wordcount <in> <out>");
      System.exit(2);
    }
    Job job = new Job(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(TokenizerMapper.class);
    job.setCombinerClass(IntSumReducer.class);
    job.setReducerClass(IntSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
    FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}
```

编写WorldCount.java
```
root@master:~# mkdir mapreduce
root@master:~# cd mapreduce/
root@master:~/mapreduce# vi WordCount.java
```
复制上面的代码,编译：
```
root@master:~/mapreduce# javac WordCount.java 
WorldCount.java:15: error: class WordCount is public, should be declared in a file named WordCount.java
public class WordCount {
       ^
WorldCount.java:8: error: package org.apache.hadoop.mapreduce does not exist
import org.apache.hadoop.mapreduce.Job;
                                  ^
WorldCount.java:9: error: package org.apache.hadoop.mapreduce does not exist
import org.apache.hadoop.mapreduce.Mapper;
```
**会发现有一堆报错**，错因是无法识别一些包:
```java
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;
```
这涉及到前面几节讲过的**Classpath**的问题，解决的办法是修改 `/etc/profile` ,添加内容至Classpath
```
JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64/
export HADOOP_HOME=/usr/local/hadoop
export JRE_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64/jre
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$HADOOP_HOME/share/hadoop/common
/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/ha
doop-mapreduce-client-core-2.7.2.jar
export PATH=$PATH:$HADOOP_HOME/bin
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib:$HADOOP_HOME/lib/nativee
"
```

就是在CLASSPATH末尾添加一行  
`$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.2.jar`

再次编译:
```
root@master:~/mapreduce# javac WordCount.java 
Note: WordCount.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
root@master:~/mapreduce# ls
WordCount$IntSumReducer.class    WordCount.class
WordCount$TokenizerMapper.class  WordCount.java
```
javac命令的两行note可以不用管，现在编译可以正常通过

### 5.4.4 打包成jar包并运行
```
root@master:~/mapreduce# jar -cvf WordCount.jar ./WordCount*.class
added manifest
adding: WordCount$IntSumReducer.class(in = 1739) (out= 739)(deflated 57%)
adding: WordCount$TokenizerMapper.class(in = 1736) (out= 754)(deflated 56%)
adding: WordCount.class(in = 1830) (out= 987)(deflated 46%)
root@master:~/mapreduce# ls
WordCount$IntSumReducer.class    WordCount.class  WordCount.java
WordCount$TokenizerMapper.class  WordCount.jar
```
运行jar包：

```hadoop jar WordCount.jar WordCount /README.txt /output```

```
root@master:~/mapreduce# hadoop jar WordCount.jar WordCount /README.txt /output
18/06/30 08:17:59 INFO client.RMProxy: Connecting to ResourceManager at master/172.19.0.2:8032
18/06/30 08:17:59 INFO input.FileInputFormat: Total input paths to process : 1
18/06/30 08:18:00 INFO mapreduce.JobSubmitter: number of splits:1
18/06/30 08:18:00 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1530344396199_0001
18/06/30 08:18:00 INFO impl.YarnClientImpl: Submitted application application_1530344396199_0001
18/06/30 08:18:00 INFO mapreduce.Job: The url to track the job: http://master:8088/proxy/application_1530344396199_0001/
18/06/30 08:18:00 INFO mapreduce.Job: Running job: job_1530344396199_0001
18/06/30 08:18:08 INFO mapreduce.Job: Job job_1530344396199_0001 running in uber mode : false
18/06/30 08:18:08 INFO mapreduce.Job:  map 0% reduce 0%
18/06/30 08:18:12 INFO mapreduce.Job:  map 100% reduce 0%
18/06/30 08:18:17 INFO mapreduce.Job:  map 100% reduce 100%
18/06/30 08:18:17 INFO mapreduce.Job: Job job_1530344396199_0001 completed successfully
18/06/30 08:18:17 INFO mapreduce.Job: Counters: 49
	File System Counters
		FILE: Number of bytes read=1836
		FILE: Number of bytes written=238315
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=1467
		HDFS: Number of bytes written=1306
		HDFS: Number of read operations=6
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=2
	Job Counters 
		Launched map tasks=1
		Launched reduce tasks=1
		Data-local map tasks=1
		Total time spent by all maps in occupied slots (ms)=2562
		Total time spent by all reduces in occupied slots (ms)=2242
		Total time spent by all map tasks (ms)=2562
		Total time spent by all reduce tasks (ms)=2242
		Total vcore-milliseconds taken by all map tasks=2562
		Total vcore-milliseconds taken by all reduce tasks=2242
		Total megabyte-milliseconds taken by all map tasks=2623488
		Total megabyte-milliseconds taken by all reduce tasks=2295808
	Map-Reduce Framework
		Map input records=31
		Map output records=179
		Map output bytes=2055
		Map output materialized bytes=1836
		Input split bytes=101
		Combine input records=179
		Combine output records=131
		Reduce input groups=131
		Reduce shuffle bytes=1836
		Reduce input records=131
		Reduce output records=131
		Spilled Records=262
		Shuffled Maps =1
		Failed Shuffles=0
		Merged Map outputs=1
		GC time elapsed (ms)=36
		CPU time spent (ms)=830
		Physical memory (bytes) snapshot=534110208
		Virtual memory (bytes) snapshot=1779810304
		Total committed heap usage (bytes)=354942976
	Shuffle Errors
		BAD_ID=0
		CONNECTION=0
		IO_ERROR=0
		WRONG_LENGTH=0
		WRONG_MAP=0
		WRONG_REDUCE=0
	File Input Format Counters 
		Bytes Read=1366
	File Output Format Counters 
		Bytes Written=1306
```

## 5.5 实验结果
reduce结果储存在HDFS的/output目录下的**part-r-00000**文件中
```
root@master:~/mapreduce# hadoop fs -ls /output
Found 2 items
-rw-r--r--   2 root supergroup          0 2018-06-30 08:18 /output/_SUCCESS
-rw-r--r--   2 root supergroup       1306 2018-06-30 08:18 /output/part-r-00000
root@master:~/mapreduce# hadoop fs -cat /output/part-r-00000
(BIS),	1
(ECCN)	1
(TSU)	1
(see	1
5D002.C.1,	1
740.13)	1
<http://www.wassenaar.org/>	1
Administration	1
Apache	1
BEFORE	1
BIS	1
Bureau	1
Commerce,	1
Commodity	1
Control	1
Core	1
Department	1
ENC	1
Exception	1
Export	2
For	1
Foundation	1
Government	1
Hadoop	1
Hadoop,	1
Industry	1
Jetty	1
License	1
Number	1
Regulations,	1
SSL	1
Section	1
Security	1
See	1
Software	2
Technology	1
The	4
This	1
U.S.	1
Unrestricted	1
about	1
algorithms.	1
and	6
and/or	1
another	1
any	1
as	1
asymmetric	1
at:	2
both	1
by	1
check	1
classified	1
code	1
code.	1
concerning	1
country	1
country's	1
country,	1
cryptographic	3
currently	1
details	1
distribution	2
eligible	1
encryption	3
exception	1
export	1
following	1
for	3
form	1
from	1
functions	1
has	1
have	1
http://hadoop.apache.org/core/	1
http://wiki.apache.org/hadoop/	1
if	1
import,	2
in	1
included	1
includes	2
information	2
information.	1
is	1
it	1
latest	1
laws,	1
libraries	1
makes	1
manner	1
may	1
more	2
mortbay.org.	1
object	1
of	5
on	2
or	2
our	2
performing	1
permitted.	1
please	2
policies	1
possession,	2
project	1
provides	1
re-export	2
regulations	1
reside	1
restrictions	1
security	1
see	1
software	2
software,	2
software.	2
software:	1
source	1
the	8
this	3
to	2
under	1
use,	2
uses	1
using	2
visit	1
website	1
which	2
wiki,	1
with	1
written	1
you	1
your	1
```

至此就完成了编写WordCount的实验。
