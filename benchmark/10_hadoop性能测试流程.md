# hadoop性能测试流程 

hadoop自带有性能测试程序，jar包位于$HADOOP_HOME/share/hadoop/mapreduce/路径下  
不带参数的运行jar包可查看所有测试程序:  
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-client-jobclient-2.7.7-tests.jar 
An example program must be given as the first argument.
Valid program names are:
  DFSCIOTest: Distributed i/o benchmark of libhdfs.
  DistributedFSCheck: Distributed checkup of the file system consistency.
  JHLogAnalyzer: Job History Log analyzer.
  MRReliabilityTest: A program that tests the reliability of the MR framework by injecting faults/failures
  NNdataGenerator: Generate the data to be used by NNloadGenerator
  NNloadGenerator: Generate load on Namenode using NN loadgenerator run WITHOUT MR
  NNloadGeneratorMR: Generate load on Namenode using NN loadgenerator run as MR job
  NNstructureGenerator: Generate the structure to be used by NNdataGenerator
  SliveTest: HDFS Stress Test and Live Data Verification.
  TestDFSIO: Distributed i/o benchmark.
  fail: a job that always fails
  filebench: Benchmark SequenceFile(Input|Output)Format (block,record compressed and uncompressed), Text(Input|Output)Format (compressed and uncompressed)
  largesorter: Large-Sort tester
  loadgen: Generic map/reduce load generator
  mapredtest: A map/reduce test check.
  minicluster: Single process HDFS and MR cluster.
  mrbench: A map/reduce benchmark that can create many small jobs
  nnbench: A benchmark that stresses the namenode.
  sleep: A job that sleeps at each map and reduce task.
  testbigmapoutput: A map/reduce program that works on a very big non-splittable file and does identity map/reduce
  testfilesystem: A test for FileSystem read/write.
  testmapredsort: A map/reduce program that validates the map-reduce framework's sort.
  testsequencefile: A test for flat files of binary key value pairs.
  testsequencefileinputformat: A test for sequence file input format.
  testtextinputformat: A test for text input format.
  threadedmapbench: A map/reduce benchmark that compares the performance of maps with multiple spills over maps with 1 spill
```  

## 1.TestDFSIO:集群的 I/O 性能测试  
首先正常启动好集群。  

### 1.1 写测试    
两个文件，一个50MB
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-client-jobclient-2.7.7-tests.jar TestDFSIO -write -nrFiles 2 -size 50  
```  
输出:  
```
19/03/10 10:10:12 INFO fs.TestDFSIO: ----- TestDFSIO ----- : write
19/03/10 10:10:12 INFO fs.TestDFSIO:             Date & time: Sun Mar 10 10:10:12 CST 2019
19/03/10 10:10:12 INFO fs.TestDFSIO:         Number of files: 2
19/03/10 10:10:12 INFO fs.TestDFSIO:  Total MBytes processed: 100
19/03/10 10:10:12 INFO fs.TestDFSIO:       Throughput mb/sec: 25.33
19/03/10 10:10:12 INFO fs.TestDFSIO:  Average IO rate mb/sec: 25.39
19/03/10 10:10:12 INFO fs.TestDFSIO:   IO rate std deviation: 1.21
19/03/10 10:10:12 INFO fs.TestDFSIO:      Test exec time sec: 34.21
``` 

### 1.2 读测试  
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-client-jobclient-2.7.7-tests.jar TestDFSIO -read -nrFiles 2 -size 50  
```  
输出:  
```
19/03/10 10:13:24 INFO fs.TestDFSIO: ----- TestDFSIO ----- : read
19/03/10 10:13:24 INFO fs.TestDFSIO:             Date & time: Sun Mar 10 10:13:24 CST 2019
19/03/10 10:13:24 INFO fs.TestDFSIO:         Number of files: 2
19/03/10 10:13:24 INFO fs.TestDFSIO:  Total MBytes processed: 100
19/03/10 10:13:24 INFO fs.TestDFSIO:       Throughput mb/sec: 476.19
19/03/10 10:13:24 INFO fs.TestDFSIO:  Average IO rate mb/sec: 476.23
19/03/10 10:13:24 INFO fs.TestDFSIO:   IO rate std deviation: 4.54
19/03/10 10:13:24 INFO fs.TestDFSIO:      Test exec time sec: 29.46
```    

以上测试数据解释：
**Throughput mb/sec 和 Average IO rate mb/sec** 是两个最重要的性能衡量指标：Throughput mb/sec 衡量每个 map task 的平均吞吐量，Average IO rate mb/sec 衡量每个文件的平均 IO 速度。
**IO rate std deviation**：标准差，高标准差表示数据散布在一个大的值域中，这可能意味着群集中某个节点存在性能相关的问题，这可能和硬件或软件有关。

### 1.3 测试后清除数据  
删除历史数据，避免之前测试的影响  
``` 
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-client-jobclient-2.7.7-tests.jar TestDFSIO -clean
```  

### 1.4 原理(参考别人博客)  
TestDFSIO程序原理：使用多个Map Task模拟多路的并发读写。通过自己的Mapper class用来读写数据，生成统计信息; 通过自己的 Reduce Class 来收集并汇总各个 Map Task 的统计信息，主要涉及到三个文件: AccumulatingReducer.java, IOMapperBase.java, TestDFSIO.java。  

大致运行过程：  
(1)根据 Map Task 的数量将相应个数的Control控制文件写入HDFS，这些控制文件仅包含一行内容：<数据文件名，数据文件大小> ;  
(2)启动 MapReduceJob，IOMapperBase Class 中的 Map 方法将Control 文件作为输入文件，读取内容，将数据文件名和大小作为参数传递给自定义的 doIO 函数，进行实际的数据读写工作。而后将数据大小和 doIO 执行的时间传递给自定义的 collectStatus 函数，进行统计数据的输出工作 ;  
(3)doIO 的实现：TestDFSIO 重载并实现 doIO 函数，将指定大小的数据写入 HDFS 文件系统;  
(4)collectStatus 的实现：TestDFSIO 重载并实现 collectStatus 函数，将任务数量，以及数据大小，完成时间等相关数据作为 Map Class 的结果输出;  
(5)统计数据用不同的前缀标识，例如 l: (stand for long), s: (stand for string) etc;  
(6)执行唯一的一个 Reduce 任务，收集各个 Map Class 的统计数据，使用 AccumulatingReducer 进行汇总统计;    
(7)最后当 MapReduceJob 完成以后，调用 analyzeResult 函数读取最终的统计数据并输出到控制台和本地的 Log 文件中;    

可以看整个过程中，实际通过 MR 框架进行读写 Shuffle 的只是 Control 文件，数据量非常小，所以 MR 框架本身的数据传输对测试的影响很小，可以忽略不计，测试结果基本是取决于 HDFS 的读写性能的。  

## 2.TeraSort:集群的计算性能测试   
这个不会输出任务运行时间。
### 2.1 测试数据生成
测试数据量为100M，于 100 字节一行，则设定行数为 1000000  
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-examples-2.7.7.jar teragen 1000000 /input
```  
### 2.2 运行TeraSort测试程序  
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-examples-2.7.7.jar terasort /input /output
```  

### 2.3 结果校验  
TeraSort 自带校验程序 TeraValidate，用来检验排序输出结果是否是有序的： 
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-examples-2.7.7.jar teravalidate /output /validate
```  

### 2.4 原理  
对输入文件按 Key 进行全局排序。TeraSort 针对的是大批量的数据，在实现过程中为了保证 Reduce 阶段各个 Reduce Job 的负载平衡，以保证全局运算的速度，TeraSort 对数据进行了预采样分析。  

大致运行过程：  
从 job 框架上看，为了保证 Reduce 阶段的负载平衡，使用 jobConf.setPartitionerClass 自定义了 Partitioner Class 用来对数据进行分区，在 map 和 reduce 阶段对数据不做额外处理。Job 流程如下：  
(1)对数据进行分段采样：例如将输入文件最多分割为 10 段，每段读取最多 100,000 行数据作为样本，统计各个 Key 值出现的频率并对 Key 值使用内建的 QuickSort 进行快速排序（这一步是 JobClient 在单个节点上执行的，采样的运算量不能太大）;  
(2)将样本统计结果中位于样本统计平均分段处的 Key 值（例如 n/10 处 n=[1..10]）做为分区的依据以 DistributedCache 的方式写入文件，这样在 MapReduce 阶段的各个节点都能够 Access 这个文件。如果全局数据的 Key 值分布与样本类似的话，这也就代表了全局数据的平均分区的位置;  
(3)在 MapReduceJob 执行过程中，自定义的 Partitioner 会读取这个样本统计文件，根据分区边界 Key 值创建一个两级的索引树用来快速定位特定 Key 值对应的分区（这个两级索引树是根据 TeraSort 规定的输入数据的特点定制的，对普通数据不一定具有普遍适用性，比如 Hadoop 内置的 TotalPartitioner 就采用了更通用的二分查找法来定位分区）;  

TeraSort 使用了 Hadoop 默认的 IdentityMapper 和 IdentityReducer。IdentityMapper 和 IdentityReducer 对它们的输入不做任何处理，将输入 k,v 直接输出；也就是说是完全是为了走框架的流程而空跑。这正是 Hadoop 的 TeraSort 的巧妙所在，它没有为排序而实现自己的 mapper 和 reducer，而是完全利用 Hadoop 的 Map Reduce 框架内的机制实现了排序。 而也正因为如此，我们可以在集群上利用 TeraSort 来测试 Hadoop。  
## 3.参考博客  
https://www.itcodemonkey.com/article/7594.html  
https://blog.csdn.net/qq_30408111/article/details/78742336