# 大数据领域的 Benchmark
## 一、Benchmark简介
Benchmark是一个评价方式，在整个计算机领域有着长期的应用。正如维基百科上的解释“As computer architecture advanced, it became more difficult to compare the performance of various computer systems simply by looking at their specifications.Therefore, tests were developed that allowed comparison of different architectures.”Benchmark在计算机领域应用最成功的就是性能测试，主要测试负载的执行时间、传输速度、吞吐量、资源占用率等。

## 二、Benchmark的组成
Benchmark的核心由3部分组成：数据集、 工作负载、度量指标。

1、数据集
数据类型分为结构化数据、半结构化数据和非结构化数据。由于大数据环境下的数据类型复杂，负载多样，所以大数据Benchmark需要生成3种类型的数据和对应负载。

1）结构化数据：传统的关系数据模型，可用二维表结构表示。典型场景有电商交易、财务系统、医疗HIS数据库、政务信息化系统等等；

2）半结构化数据：类似XML、HTML之类，自描述，数据结构和内容混杂在一起。典型应用场景有邮件系统、Web搜索引擎存储、教学资源库、档案系统等等，可以考虑使用Hbase等典型的KeyValue存储；

3）非结构化数据：各种文档、图片、视频和音频等。典型的应用有视频网站、图片相册、交通视频监控等等。

2、工作负载
互联网领域数据庞大，用户量大，成为大数据问题产生的天然土壤。对工作负载理解和设计可以从以下几个维度来看

1）密集计算类型：CPU密集型计算、IO密集型计算、网络密集型计算；

2）计算范式：SQL、批处理、流计算、图计算、机器学习；

3）计算延迟：在线计算、离线计算、实时计算；

4）应用领域：搜索引擎、社交网络、电子商务、地理位置、媒体、游戏。

3、度量指标
性能高估的两大利器就是Benchmark和Profile工具。Benchmark用压力测试挖掘整个系统的性能状况，而Profile工具最大限度地呈现系统的运行时状态和性能指标，方便用户诊断性能问题和进行调优。

1）工具的使用

   a）在架构层面：perf、nmon等工具和命令；

   b）在JVM层面：btrace、Jconsole、JVisualVM、JMap、JStack等工具和命令；

   c）在Spark层面：web ui、console log，也可以修改Spark源码打印日志进行性能监控。

2）度量指标

   a）从架构角度度量：浮点型操作密度、整数型操作密度、指令中断、cache命中率、TLB命中；

   b）从Spark系统执行时间和吞吐的角度度量：Job作业执行时间、Job吞吐量、Stage执行时间、Stage吞吐量、Task执行时间、Task吞吐量；

   c）从Spark系统资源利用率的角度度量：CPU在指定时间段的利用率、内存在指定时间段的利用率、磁盘在指定时间段的利用率、网络带宽在指定时间段的利用率；

   d）从扩展性的角度度量：数据量扩展、集群节点数据扩展（scale out）、单机性能扩展（scale up）。

## 三、Benchmark的运用
1、Hibench：由Intel开发的针对Hadoop的基准测试工具，开源的，用户可以到Github库中下载

2、Berkeley BigDataBench：随着Spark的推出，由AMPLab开发的一套大数据基准测试工具，官网介绍

3、Hadoop GridMix：Hadoop自带的Benchmark，作为Hadoop自带的测试工具使用方便、负载经典，应用广泛

4、Bigbench：由Teradata、多伦多大学、InfoSizing、Oracle开发，其设计思想和利用扩展具有研究价值，可以参阅论文Bigbench:Towards an industry standard benchmark for big data analytics。

5、BigDataBenchmark：由中科院研发，官方介绍

6、TPC-DS：广泛应用于SQL on Hadoop的产品评测

7、其他的Benchmark：Malstone、Cloud Harmony、YCSB、SWIM、LinkBench、DFSIO、Hive performance Benchmark(Pavlo)等等


# 参考
1. 大数据领域的Benchmark介绍 . https://blog.csdn.net/u012050154/article/details/50729725