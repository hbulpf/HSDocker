# 大数据系列实验

### 1. 实验开发环境 
1. jdk1.7.0_79 
1. hadoop2.7.1 
1. Eclipse oxegen
2. eclipse-hadoop-plugin（基于Eclipse的Hadoop插件）
1. bigdata相关插件（包含Hadoop、HBase、 Hive、Spark、Scala、Storm、ZooKeeper、Redis、MongoDB、LevelDB在内的大数据组件。）
>     下载地址： 
>     链接：https://pan.baidu.com/s/1OriXAXZENZyO-YdFrJrFEw
>     密码：kn7j

### 2. 实验列表
1. [实验1_基本操作](./实验1_基本操作.md)
1. [实验2_HDFS_部署HDFS](./实验2_HDFS_部署HDFS.md)
1. [实验3_HDFS_读写HDFS文件](./实验3_HDFS_读写HDFS文件.md)
1. [实验4_YARN_部署YARN集群](./实验4_YARN_部署YARN集群.md)
1. [实验5_MapReduce_单词计数](./实验5_MapReduce_单词计数.md)
1. [实验6_MapReduce_二次排序](./实验6_MapReduce_二次排序.md)
1. [实验8_MapReduce_Join操作](./实验8_MapReduce_Join操作.md)
1. [实验9_MapReduce_分布式缓存](./实验9_MapReduce_分布式缓存.md)
1. [实验10_Hive_部署Hive](./实验10_Hive_部署Hive.md)
1. [实验11_Hive_新建Hive表](./实验11_Hive_新建Hive表.md)
1. [实验12_Hive_Hive分区](./实验12_Hive_Hive分区.md)
1. [实验13_Spark_部署Spark集群](./实验13_Spark_部署Spark集群.md)
1. [实验14_Spark_SparkWordCount](./实验14_Spark_SparkWordCount.md)
1. [实验15_Spark_RDD综合实验](./实验15_Spark_RDD综合实验.md)
1. [实验16_Spark_Spark综例](./实验16_Spark_Spark综例.md)
1. [实验17_Spark_Spark_SQL](./实验17_Spark_Spark_SQL.md)
1. [实验18_Spark_Spark_Streaming](./实验18_Spark_Spark_Streaming.md)
1. [实验19_Spark_GraphX](./实验19_Spark_GraphX.md)
1. [实验20_部署ZooKeeper](./实验20_部署ZooKeeper.md)
1. [实验21_ZooKeeper进程协作](./实验21_ZooKeeper进程协作.md)
1. [实验22_部署HBase](./实验22_部署HBase.md)
1. [实验23_新建HBase表](./实验23_新建HBase表.md)
1. [实验24_部署Storm](./实验24_部署Storm.md)
1. [实验25_实时WordCountTopology](./实验25_实时WordCountTopology.md)
1. [实验26_文件数据Flume至HDFS](./实验26_文件数据Flume至HDFS.md)
1. [实验27_Kafka订阅推送示例](./实验27_Kafka订阅推送示例.md)
1. [实验28_Pig版WordCount](./实验28_Pig版WordCount.md)
1. [实验29_Redis部署与简单使用](./实验29_Redis部署与简单使用.md)
1. [实验30_MapReduce与Spark读写Redis](./实验30_MapReduce与Spark读写Redis.md)
1. [实验31_MongoDB](./实验31_MongoDB.md)
1. [实验32_LevelDB读写](./实验32_LevelDB读写.md)
1. [实验33?Mahout_K-means](./实验33?Mahout_K-means.md)
1. [实验34_Spark实现K-Means](./实验34_Spark实现K-Means.md)
1. [实验35_Spark实现SVM](./实验35_Spark实现SVM.md)
1. [实验36_Spark实现FP-Growth](./实验36_Spark实现FP-Growth.md)
1. [实验39_推荐系统](./实验39_推荐系统.md)
1. [实验40_综合实战环境大数据](./实验40_综合实战环境大数据.md)
1. [实验42_贷款风险评估](./实验42_贷款风险评估.md)

# 实验过程中的问题

## 实验中遇到的问题  

### **实验1~4:**   
Hadoop基础实验，没有太大问题，比较不好理解的是实验4的 Distributed shell 

### **实验5~9:**  
都是mapreduce实验，都是需要实际进行代码编写,如果用javac命令进行编译要注意修改/etc/profile的CLASSPATH部分，实验中也有讲到。  

如果用开发工具的话，注意要导入hadoop里的一些jar包,一直只要用到两个jar包:  
hadoop-common-2.7.2.jar, hadoop-mapreduce-client-core-2.7.2.jar  
**common jar包在/usr/local/hadoop/share/hadoop/common/目录下  
mapreduce jar包在/usr/local/hadoop/share/hadoop/mapreduce/目录下**  

>代码上的话实验6跟实验8代码比较难理解，实验8实验结果也一直有乱码出现(个人觉得代码上应该是没有错误的)  

### **实验10~12:**   
Hive实验部分,主要是安装部署和一些基本操作。  

Hive的部署主要有三种模式:  
**1.内嵌模式:** 元数据保存在内嵌的derby中（使用很不方便）,quit退出交互之后操作记录并不会保存。  
**2.本地模式:** 本地安装mysql,替代derby存储元数据, 本地模式的安装还算比较简单( 参考写的文档Hive本地模式部署)，能成功连接上。远程安装mysql（即在别的主机上安装mysql并连接就会出现问题，尝试过创建mysql容器去部署本地模式，但最后结果是连接不上mysql)  
**3.远程模式:** hive服务和metastore在不同的进程内，可能是不同的机器。（这部分没有去实验过，不太了解）  

### **实验13~19:**   
均是Spark实验，实验13~16比较简单，都是一些比较简单的基础操作。实验17~19就出现了不少问题。  

首先Spark有两种启动模式，单机模式和集群模式。  

**实验17是Spark SQL**: 原先实验是要求在集群模式下启动的，前面的操作都正常，到查询数据那就会报错，无法获取先前插入的数据，原因不明。  
**实验18是Spark Streaming**: 安装原实验进行操作无法获得相应的实验结果，有错误。但是运行Spark自带的Spark Streaming例子则可以成功运行。  
**实验19是GraphX**: 代码比较复杂，且无法运行jar包！  

### **实验20~21:**  
zookeeper的安装部署和一些基本操作，实验内容比较简单。  

### **实验22~23:**  
HBase实验，实验内容比较简单，就是安装部署和一些简单使用，**唯一要注意的比较奇怪的点是在实验22里使用HBase Shell时如果事先没有修改/etc/hosts文件添加主机域名的映射会无法正常使用**。  

### **实验24~25:**  
Storm实验，因为storm跟hadoop,spark没有什么关系，所以单独制作了镜像demo4。 实验内容也不是很复杂。  

### **实验26~28:**  
都是一些组件的安装部署和简单使用。  

实验26: Flume  实验27: Kafka 实验28: Pig  

### **实验29~30:**  
Redis实验，安装需要用make命令进行编译。实验不复杂。  

### **实验31~32:** 
两个数据库,MongoDB和LevelDB，实验过程没有遇到太多问题，就是对这两个数据库比较陌生。  

### **实验33~36:**  
都涉及到机器学习。
实验33 Mahout 是通过hadoop进行一些机器学习任务。 
实验34~36 是spark 自带的机器学习库Mllib，机器学习部分了解得不多，所以只是按实验操作实验了一遍，具体效果不清楚。  

### **实验37~42:**  
综合试验

----
>以上实验都在容器中进行





