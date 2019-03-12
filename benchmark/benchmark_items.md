# 测试项
## Hadoop HDFS 测试
### 基本功能测试
1. 列出目录，列出文件
1. 创建/删除目录
1. 上传/下载文件
1. 删除文件
1. 写速度测试，读文件速度测试 [参考](https://blog.csdn.net/flygoa/article/details/52127382)
1. 单词统计测试

### 基准性能测试
1. I/O 性能性能测试: TestDFSIO
1. 计算性能测试: TeraSort
1. nnbench
1. mrbench

可用 Haoop自带工具 [Gridmix](https://hadoop.apache.org/docs/r2.7.7/hadoop-gridmix/GridMix.htm)进行测试
### 部分原理
#### TestDFSIO原理
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


#### TeraSort原理
对输入文件按 Key 进行全局排序。TeraSort 针对的是大批量的数据，在实现过程中为了保证 Reduce 阶段各个 Reduce Job 的负载平衡，以保证全局运算的速度，TeraSort 对数据进行了预采样分析。  

大致运行过程：  
从 job 框架上看，为了保证 Reduce 阶段的负载平衡，使用 jobConf.setPartitionerClass 自定义了 Partitioner Class 用来对数据进行分区，在 map 和 reduce 阶段对数据不做额外处理。Job 流程如下：  
(1)对数据进行分段采样：例如将输入文件最多分割为 10 段，每段读取最多 100,000 行数据作为样本，统计各个 Key 值出现的频率并对 Key 值使用内建的 QuickSort 进行快速排序（这一步是 JobClient 在单个节点上执行的，采样的运算量不能太大）;  
(2)将样本统计结果中位于样本统计平均分段处的 Key 值（例如 n/10 处 n=[1..10]）做为分区的依据以 DistributedCache 的方式写入文件，这样在 MapReduce 阶段的各个节点都能够 Access 这个文件。如果全局数据的 Key 值分布与样本类似的话，这也就代表了全局数据的平均分区的位置;  
(3)在 MapReduceJob 执行过程中，自定义的 Partitioner 会读取这个样本统计文件，根据分区边界 Key 值创建一个两级的索引树用来快速定位特定 Key 值对应的分区（这个两级索引树是根据 TeraSort 规定的输入数据的特点定制的，对普通数据不一定具有普遍适用性，比如 Hadoop 内置的 TotalPartitioner 就采用了更通用的二分查找法来定位分区）;  

TeraSort 使用了 Hadoop 默认的 IdentityMapper 和 IdentityReducer。IdentityMapper 和 IdentityReducer 对它们的输入不做任何处理，将输入 k,v 直接输出；也就是说是完全是为了走框架的流程而空跑。这正是 Hadoop 的 TeraSort 的巧妙所在，它没有为排序而实现自己的 mapper 和 reducer，而是完全利用 Hadoop 的 Map Reduce 框架内的机制实现了排序。 而也正因为如此，我们可以在集群上利用 TeraSort 来测试 Hadoop。  


### 过程参看
1. 进行集群的 I/O 性能测试、计算性能测试 . https://www.itcodemonkey.com/article/7594.html
1. hadoop基本测试方法 . https://blog.csdn.net/qq_30408111/article/details/78742336

## Hive 测试
### 基本功能测试

### 基准性能测试


## HBase 测试
### 基本功能测试

### 基准性能测试


## Spark 测试
### 基本功能测试

### 基准性能测试


## 机器学习 测试
### 基本功能测试

### 基准性能测试


# 参考
1. Hadoop2.7.0基本功能测试 . https://blog.csdn.net/flygoa/article/details/52127382
1. hadoop基本测试方法 . https://blog.csdn.net/qq_30408111/article/details/78742336