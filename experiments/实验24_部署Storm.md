# 实验二十四 部署Storm

## 24.1 实验目的  
1.掌握Storm基础简介及体系架构;   
2.掌握Storm集群安装部署; 
3.掌握Storm和Zookeeper之间的关系，并加深对Storm架构和原理的理解。  

## 24.2 实验要求  
1.巩固学习下实验一、实验二十;  
2.部署3个节点的Storm集群，以master节点作为主节点，其他两个slave节点作为从节点并引用外部Zookeeper。  

## 24.3 实验原理
Storm简介：**Storm是一个分布式的、高容错的基于数据流的实时处理系统**，可以简单、可靠的处理大量的数据流。Storm支持水平扩展，具有高容错性，保证每个消息都会得到处理，而且处理速度很快（在一个小集群中，每个结点每秒可以处理数以百万计的消息），它有以下特点：编程模型简单、可扩展、高可靠性、高容错性、支持多种编程语言、支持本地模式、高效。Storm有很多使用场景：如实时分析，在线机器学习，持续计算，分布式RPC，ETL等等。  

体系架构：Storm共有两层体系结构，**第一层采用master/slave架构，第二层为DAG流式处理器**，第一层资源管理器主要负责管理集群资源、响应和调度用户任务，第二层流式处理器则实际执行用户任务。  

集群资源管理层：Storm的集群资源管理器采用master/slave架构，主节点即控制节点(master node)和从节点即工作节点(worker node)。控制节点上面运行一个叫Nimbus后台服务程序,它的作用类似Hadoop里面的JobTracker，**Nimbus负责在集群里面分发代码，分配计算任务给机器，并且监控状态。每一个工作节点上面运行一个叫做Supervisor的服务程序。Supervisor会监听分配给它那台机器的工作，根据需要启动/关闭工作进程worker**。每一个工作进程执行一个topology的一个子集；一个运行的topology由运行在很多机器上的很多工作进程worker组成。(**一个supervisor里面有多个worker，一个worker是一个JVM**。可以配置worker的数量，对应的是conf/storm.yaml中的supervisor.slot的数量），架构图如图所示:  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex24/1.gif)  

**称集群信息(Nimbus协议、Supervisor节点位置) 、任务分配信息等关键数据为元数据。Storm使用ZooKeeper集群来共享元数据**，这些元数据对Storm非常重要，比如Nimbus通过这些元数据感知Supervisor节点，Supervisor通过Zookeeper集群感知任务分配情况。Nimbus和Supervisor之间的所有协调工作都是通过Zookeeper集群完成。另外，Nimbus进程和Supervisor进程都是快速失败(fail-fast)和无状态的｡所有的状态要么在zookeeper里面, 要么在本地磁盘上。这也就意味着你可以用kill-9来杀死Nimbus和Supervisor进程,然后再重启它们，就好像什么都没有发生过，这个设计使得Storm异常的稳定。  

数据模型：Storm实现了一种数据流模型，其中数据持续地流经一个转换实体网络。一个数据流的抽象称为一个流（stream），这是一个无限的元组序列。元组（tuple）就像一种使用一些附加的序列化代码来表示标准数据类型（比如整数、浮点和字节数组）或用户定义类型的结构。每个流由一个唯一ID定义，这个ID可用于构建数据源和接收器（sink）的拓扑结构。流起源于喷嘴（spout），Spout将数据从外部来源流入 Storm 拓扑结构中。接收器（或提供转换的实体）称为螺栓（bolt）。螺栓实现了一个流上的单一转换和一个 Storm 拓扑结构中的所有处理。Bolt既可实现 MapReduce之类的传统功能，也可实现更复杂的操作（单步功能），比如过滤、聚合或与数据库等外部实体通信。典型的 Storm 拓扑结构会实现多个转换，因此需要多个具有独立元组流的Bolt。Bolt和Spout都实现为Linux系统中的一个或多个任务。  

## 24.4 实验步骤  
本实验主要演示Storm集群的安装部署，Storm依赖于Zookeeper，所以该实验大致可分为部署Zookeeper、部署Storm、启动Storm集群三个大步骤。这次实验使用的zookeeper版本是3.4.10，storm版本是1.1.0。

### 24.4.1 安装JDK
参考之前做过的实验  

### 24.4.2 安装zookeeper并启动
参考实验20

### 24.4.3　安装storm　　
[storm下载链接](http://storm.apache.org/downloads.html)  

下载安装包后，解压路径至/usr/local/storm  

修改配置文件,进入conf目录，要修改的只有storm.yaml:  
```
########### These MUST be filled in for a storm configuration
 storm.zookeeper.servers:
     - "master"
     - "hadoop-slave1"
     - "hadoop-slave2"
# 
 nimbus.seeds: ["master"]
# 
```
找到此处修改，要注意的是每个配置项前面必须留有空格，否则会无法识别(即"master"跟"-"之前要有空格)  

**storm.zookeeper.servers表示配置Zookeeper集群地址**。注意，如果zookeeper集群中使用的不是默认端口，则还需要配置storm.zookeeper.port，**nimbus.seeds表示配置主控节点**，可以配置多个。  

通过scp命令拷贝至slave节点:  
```
root@master:~# scp -r /usr/local/storm hadoop-slave1:/usr/local/
root@master:~# scp -r /usr/local/storm hadoop-slave2:/usr/local/
```  

启动storm:(首先要先启动好zookeeper)  

在master节点: 进入bin目录  
```
root@master:/usr/local/storm/bin# ./storm nimbus >/dev/null 2>&1 &
root@master:/usr/local/storm/bin# ./storm ui >/dev/null 2>&1 &
```
**一个是启动nimbus,一个是启动web UI**

在slave节点: 进入bin目录:  
```
root@hadoop-slave1:/usr/local/storm/bin# ./storm supervisor >/dev/null 2>&1 &
```  
**启动supervisor服务**

## 24.5 实验结果  
通过jps命令查看各节点进程:  

master:  
```
root@master:/usr/local/storm/bin# jps                             
136 nimbus
137 core
606 Jps
78 QuorumPeerMain
```

slave:  
```
root@hadoop-slave1:/usr/local/storm/bin# jps  
70 QuorumPeerMain
123 Supervisor
332 Jps
```  

进入Web UI:(打开浏览器输入172.19.0.2:8080)  172.19.0.2为master ip  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex24/Screenshot%20from%202018-08-03%2011-39-34.png)








