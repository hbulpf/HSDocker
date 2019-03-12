# hadoop性能测试  

hadoop自带有性能测试程序，jar包位于 `$HADOOP_HOME/share/hadoop/mapreduce/` 路径下。不带参数的运行jar包可查看所有测试程序:  
```
[root@node04 mapreduce]# hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.7-tests.jar 
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

## 1. TestDFSIO:集群的 I/O 性能测试  
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
**Throughput mb/sec 和 Average IO rate mb/sec** 是两个最重要的性能衡量指标：
+ Throughput mb/sec：衡量每个 map task 的平均吞吐量，
+ Average IO rate mb/sec：衡量每个文件的平均 IO 速度。
+ IO rate std deviation：标准差，高标准差表示数据散布在一个大的值域中，这可能意味着群集中某个节点存在性能相关的问题，这可能和硬件或软件有关。

### 1.3 测试后清除数据  
删除历史数据，避免之前测试的影响  
``` 
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-client-jobclient-2.7.7-tests.jar TestDFSIO -clean
```  
## 2.TeraSort:集群的计算性能测试   
这个不会输出任务运行时间。
### 2.1 测试数据生成
测试数据量为100M，于 100 字节一行，则设定行数为 1000000  
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-examples-2.7.7.jar teragen 1000000 /input
```  
### 2.2 运行TeraSort测试程序  
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-examples-2.7.7.jar teragen 1000000 /input
```  

### 2.3 结果校验  
TeraSort 自带校验程序 TeraValidate，用来检验排序输出结果是否是有序的： 
```
[root@node04 mapreduce]# hadoop jar hadoop-mapreduce-examples-2.7.7.jar teravalidate /output /validate
```  

## 3.参考
1. 进行集群的 I/O 性能测试、计算性能测试 . https://www.itcodemonkey.com/article/7594.html
1. hadoop基本测试方法 . https://blog.csdn.net/qq_30408111/article/details/78742336