# 大数据领域的 Benchmark
## 一、Benchmark简介
Benchmark是一个评价方式，在整个计算机领域有着长期的应用。Benchmark在计算机领域应用最成功的就是性能测试，主要测试负载的**执行时间、传输速度、吞吐量、资源占用率**等。

## 二、Benchmark的组成
Benchmark的核心由3部分组成：数据集、 工作负载、度量指标。

### 1、数据集
数据类型分为结构化数据、半结构化数据和非结构化数据。由于大数据环境下的数据类型复杂，负载多样，所以大数据Benchmark需要生成3种类型的数据和对应负载。   
1. 结构化数据：传统的关系数据模型，可用二维表结构表示。典型场景有电商交易、财务系统、医疗HIS数据库、政务信息化系统等等；
2. 半结构化数据：类似XML、HTML之类，自描述，数据结构和内容混杂在一起。典型应用场景有邮件系统、Web搜索引擎存储、教学资源库、档案系统等等，可以考虑使用Hbase等典型的KeyValue存储； 
3. 非结构化数据：各种文档、图片、视频和音频等。典型的应用有视频网站、图片相册、交通视频监控等等。

### 2、工作负载
互联网领域数据庞大，用户量大，成为大数据问题产生的天然土壤。对工作负载理解和设计可以从以下几个维度来看: 

1. 密集计算类型：CPU密集型计算、IO密集型计算、网络密集型计算；   
2. 计算范式：SQL、批处理、流计算、图计算、机器学习；   
3. 计算延迟：在线计算、离线计算、实时计算；   
4. 应用领域：搜索引擎、社交网络、电子商务、地理位置、媒体、游戏。   

### 3、度量指标
性能评估的两大利器就是Benchmark和Profile工具。Benchmark用压力测试挖掘整个系统的性能状况，而Profile工具最大限度地呈现系统的运行时状态和性能指标，方便用户诊断性能问题和进行调优。

1）工具的使用
   1. 在架构层面：perf、nmon等工具和命令；
   2. 在JVM层面：btrace、Jconsole、JVisualVM、JMap、JStack等工具和命令；
   3. 在Spark层面：web ui、console log，也可以修改Spark源码打印日志进行性能监控。

2）度量指标 
   1. 从架构角度度量：浮点型操作密度、整数型操作密度、指令中断、cache命中率、TLB命中；
   2. 从Spark系统执行时间和吞吐的角度度量：Job作业执行时间、Job吞吐量、Stage执行时间、Stage吞吐量、Task执行时间、Task吞吐量；
   3. 从Spark系统资源利用率的角度度量：CPU在指定时间段的利用率、内存在指定时间段的利用率、磁盘在指定时间段的利用率、网络带宽在指定时间段的利用率；
   4. 从扩展性的角度度量：数据量扩展、集群节点数据扩展（scale out）、单机性能扩展（scale up）。

## 三、Benchmark的运用
- [Hibench](https://github.com/intel-hadoop/HiBench)：由Intel开发的针对Hadoop的基准测试工具，开源的，用户可以到Github库中下载
- Berkeley BigDataBench：随着Spark的推出，由AMPLab开发的一套大数据基准测试工具，官网介绍
- Hadoop GridMix：Hadoop自带的Benchmark，作为Hadoop自带的测试工具使用方便、负载经典，应用广泛
- Bigbench：由Teradata、多伦多大学、InfoSizing、Oracle开发，其设计思想和利用扩展具有研究价值，可以参阅论文Bigbench:Towards an industry standard benchmark for big data analytics。
- BigDataBenchmark：由中科院研发，官方介绍
- TPC-DS：广泛应用于SQL on Hadoop的产品评测
- 其他的Benchmark：Malstone、Cloud Harmony、YCSB、SWIM、LinkBench、DFSIO、Hive performance Benchmark(Pavlo)等等

### [Hibench](https://github.com/intel-hadoop/HiBench)
Hibench作为一个测试hadoop的基准测试框架，提供了对于hive：（aggregation，scan，join），排序（sort，TeraSort），大数据基本算法（wordcount，pagerank，nutchindex），机器学习算法（kmeans，bayes），集群调度（sleep），吞吐（dfsio），以及新加入5.0版本的流测试，是一个测试大数据平台非常好用的工具。

它支持的框架有：hadoopbench、sparkbench、stormbench、flinkbench、gearpumpbench。

对这些工作负载进行分类记录如下，总体可以分为6大类：micro、ml（machine learning）、sql、graph、websearch和streaming。

##### 1. Micro基准
- Sort
使用RandomTextWriter生成测试数据，Sort工作负载对它的文本输入数据进行排序来进行基准测试

- WordCount
使用RandomTextWriter生成测试数据，WordCount工作负载对输入数据中每个单词的出现情况进行统计

- TeraSort
是由Jim Gray创建的标准基准。其输入数据由Hadoop TeraGen示例程序生成。

- Sleep
使每个任务休眠一定的时间来测试调度框架

- enhanced DFSIO (dfsioe)
增强的DFSIO通过生成大量执行写入和读取的任务来测试Hadoop集群的HDFS吞吐量。它测量每个map任务的平均I/O速率、每个map任务的平均吞吐量以及HDFS集群的聚合吞吐量。 注: 这个工作负载不支持Spark。

##### 2. Machine Learning基准

- 贝叶斯分类 (Bayes) : 是一种简单的多类分类算法，具有独立于每一对特征的假设。这个工作负载是在spark.mllib中实现并使用自动生成的文档，这些文档的单词遵循zipfian分布。关键字用于文本生成/usr/share/dict/linux.words.ords也从默认的linux文件。

- k-means聚类(Kmeans) : 是在spark.mllib中实现的K-means(一种著名的知识发现和数据挖掘的聚类算法)。输入数据集是由基于均匀分布和Guassian分布的GenKMeansDataset生成的。

- 逻辑回归(Logistic Regression, LR) : 是预测分类响应的常用方法。这个工作负载是在spark.mllib中实现， LBFGS优化器和输入数据集是LogisticRegressionDataGenerator基于随机生成决策树的平衡。它包含三种不同类型的数据类型，包括分类数据、连续数据和二进制数据。

- 交替最小二乘(ALS) : 是一种著名的协同过滤算法。这个工作负载是在spark.mllib中实现和输入数据集是由RatingDataGenerator为产品推荐系统生成的。

- 梯度增加树(GBT) : 是一种使用决策树组合的流行的回归方法。这个工作负载是在spark.mllib中实现， GradientBoostingTreeDataGenerator生成的输入数据集。

- 线性回归 : 是一个在spark.mllib中实现的工作负载。mllib SGD优化器。输入数据集是由LinearRegressionDataGenerator生成的。

- 潜在狄利克雷分配(LDA) : 是一个主题模型，它从一个文本文档集合中推断主题。这个工作负载是在spark.mllib中实现和输入数据集由LDADataGenerator生成。

- 主成分分析(PCA) : 是一种寻找旋转的统计方法，使得第一个坐标有最大的方差，而每个后续的坐标都有最大的方差。PCA在降维方面得到了广泛的应用。这个工作负载是在spark.mllib中实现。输入数据集由PCADataGenerator生成。

- 随机森林(RF) : 是决策树的集合。随机森林是最成功的分类和回归机器学习模型之一。为了降低过度拟合的风险，他们联合了许多决策树。这个工作负载是在spark.mllib中实现， RandomForestDataGenerator生成的输入数据集。

- 支持向量机(SVM) : 是大规模分类任务的标准方法。这个工作负载是在spark.mllib中实现和输入数据集由SVMDataGenerator生成。

- 奇异值分解(SVD) : 将矩阵分解成三个矩阵。这个工作负载是在spark.mllib中实现及其输入数据集由SVDDataGenerator生成。

##### 3. SQL基准

- 扫描(扫scan),连接(join),聚合(aggregation)
这些工作负载是基于SIGMOD 09论文“对大规模数据分析方法的比较”和HIVE-396进行开发的。它包含用于执行本文描述的典型OLAP查询的Hive查询(聚合和连接)。它的输入也会自动生成带有超链接的网络数据。

##### 4. Websearch基准
- PageRank : 基准PageRank算法在Spark-MLLib/Hadoop中实现(在pegasus 2.0中包含一个搜索引擎排名基准)。数据源是由Web数据生成的，其超链接遵循Zipfian分布。

- Nutch索引(nutchindexing) : 大规模搜索索引是MapReduce最重要的用途之一。这个工作负载测试Nutch中的索引子系统，这是一个流行的开源(Apache项目)搜索引擎。工作负载使用自动生成的Web数据，其超链接和单词都遵循Zipfian分布和相应的参数。用来生成网页文本的命令是默认的linux命令文件。

##### 5. Graph基准

- NWeight : 由Spark GraphX和pregel实现的一种迭代的图形并行算法。该算法计算两个n-hop的顶点之间的关联。

##### 6.Streaming基准

- 身份(Identity) 工作负载从Kafka读取输入数据，然后立即将结果写入Kafka，不涉及复杂的业务逻辑。

- 重新分区(Repartition) 工作负载从Kafka读取输入数据，并通过创建更多或更少的分区来更改并行度。它测试了流框架中的数据洗牌效率。

- 有状态Wordcount : 每隔几秒就会收到Kafka的词汇量。这将测试流框架中的有状态操作符性能和检查点/Acker成本。

- Fixwindow : 工作负载执行基于窗口的聚合。它在流框架中测试窗口操作的性能。

#### 安装 Hibench
过程参看：
1. Hibench Homepage . https://github.com/intel-hadoop/HiBench
1. 采用Hibench进行大数据平台基准性能测试 . https://blog.csdn.net/Fighingbigdata/article/details/79468898

### Hadoop GridMix

测试过程参看：
1. 进行集群的 I/O 性能测试、计算性能测试 . https://www.itcodemonkey.com/article/7594.html

# 参考
1. 大数据领域的Benchmark介绍 . https://blog.csdn.net/u012050154/article/details/50729725
1. Hibench Homepage . https://github.com/intel-hadoop/HiBench
1. 采用Hibench进行大数据平台基准性能测试 . https://blog.csdn.net/Fighingbigdata/article/details/79468898
1. Hadoop自带benchmark运行与测试. https://blog.51cto.com/7543154/1243883
1. Benchmarking and Stress Testing an Hadoop Cluster with TeraSort, TestDFSIO & Co. http://www.michael-noll.com/blog/2011/04/09/benchmarking-and-stress-testing-an-hadoop-cluster-with-terasort-testdfsio-nnbench-mrbench/
1. Apache Hadoop Gridmix . https://hadoop.apache.org/docs/r2.7.7/hadoop-gridmix/GridMix.html
1. hadoop基本测试方法 . https://blog.csdn.net/qq_30408111/article/details/78742336
1. 进行集群的 I/O 性能测试、计算性能测试 . https://www.itcodemonkey.com/article/7594.html