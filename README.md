# 容器化 Hadoop Spark 实战 #
## 一、整体思路 ##
1. 研究Springboot部署微服务的过程；研究Kubernetes（简称K8S）,Mesos调度容器的过程。最终实现基于Springboot,Docker,K8S,Mesos等开源工具快速搭建一套微服务架构的容器群。
2. 研发基于daocloud等开源工具建立支持容器的可视化管理和监控的系统。
3. 熟悉Hadoop，Spark集群的搭建过程，并抽取关键的配置参数作为大数据平台容器的启动参数。
4. 实现基于容器的自定义大数据平台管理与监控系统。其核心功能为：
	- 基本的容器监控与管理系统，
	- 支持半自动化的大数据集群搭建,
	- 封装hadoop和spark大数据平台组件并能组装为大数据集群
	- 大数据集群的较强的动态伸缩能力

## 二、docker调容器平台实验 ##
### 2.1 springboot与docker ###
1. [HelloWorld:使用springboot构建docker容器第一个demo](./springboot_docker/docker-spring-boot)

### 2.2 kubernetes 实验 ###

### 2.3 mesos 实验 ###

## 三、大数据平台实验 ##
### 1. 实验开发环境  ###
1. jdk1.7.0_79 
1. hadoop2.7.1 
1. Eclipse oxegen
2. eclipse-hadoop-plugin（基于Eclipse的Hadoop插件）
1. bigdata相关插件（包含Hadoop、HBase、 Hive、Spark、Scala、Storm、ZooKeeper、Redis、MongoDB、LevelDB在内的大数据组件。）
>     下载地址： 
>     链接：https://pan.baidu.com/s/1OriXAXZENZyO-YdFrJrFEw
>     密码：kn7j

### 2. 实验过程 ###

1. 实验1-基本操作实验
1. 实验2-HDFS实验_部署HDFS
1. 实验3-HDFS实验_读写HDFS文件
1. 实验4-YARN实验：部署YARN集群
1. 实验5-MapReduce实验：单词计数
1. 实验6-MapReduce实验：二次排序
1. 实验7-MapReduce实验：计数器
1. 实验8-MapReduce实验：Join操作
1. 实验9-MapReduce实验：分布式缓存
1. 实验10-Hive实验：部署Hive
1. 实验11-Hive实验：新建Hive表
1. 实验12-Hive实验：Hive分区
1. 实验13-Spark实验：部署Spark集群
1. 实验14-Spark实验：SparkWordCount
1. 实验15-Spark实验：RDD综合实验
1. 实验16-Spark实验：Spark综例
1. 实验17-Spark实验：SparkSQL
1. 实验18-Spark实验：SparkStreaming
1. 实验19-Spark实验：GraphX
1. 实验20-部署ZooKeeper
1. 实验21-ZooKeeper进程协作
1. 实验22-部署HBase
1. 实验23-新建HBase表
1. 实验24-部署Storm
1. 实验25-实时WordCountTopology
1. 实验26-文件数据Flume至HDFS
1. 实验27-Kafka订阅推送示例
1. 实验28-Pig版WordCount


## 四、 容器化大数据平台实验 ###
1. [使用Hadoop-2.7.2在Docker中部署Hadoop集群](./hadoopspark/demo_1-HadoopClusterRaw)
2. [基于Docker搭建定制版Hadoop集群](./hadoopspark/demo_2-docker-cluster)

## 五、 容器化深度学习实验 ###


## 六、 其他 ##
### 1. [ 容器云相关企业](./casestudy) ###
| 容器云厂商 | 容器云教育 |
| :---------- | :---------- |
|1. [灵雀云](http://www.alauda.cn/product/detail/id/68.html)|1. [云创大数据](http://www.cstor.cn/) |
|2. [七牛云](https://www.qiniu.com/products/kirk)| |
|3. [数人云](https://www.shurenyun.com/scene-bigdata.html)| | 
|4. [青云](https://www.qingcloud.com)| |
### 2. 相关项目 ###

-   **[Big Data Europe](https://www.big-data-europe.eu/)**  
   
	> [https://github.com/big-data-europe](https://github.com/big-data-europe)  
	> Integrating Big Data, software & communicaties for addressing Europe's societal challenges

## 贡献者 ##

@[**chellyk**](https://github.com/chellyk) @[**RunAtWorld**](http://www.github.com/RunAtWorld) @[**icepoint666**](https://www.github.com/icepoint666) @[**Missice**](https://github.com/Missice)  
GitHub : [https://github.com/hbulpf/HSDocker](https://github.com/hbulpf/HSDocker)

