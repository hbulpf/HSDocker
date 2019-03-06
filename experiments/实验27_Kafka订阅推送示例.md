# 实验二十七 Kafka订阅推送示例

## 27.1 实验目的  
1.掌握Kafka的安装部署；  
2.掌握Kafka的topic创建及如何生成消息和消费消息；  
3.掌握Kafka和Zookeeper之间的关系；  
4.了解Kafka如何保存数据及加深对Kafka相关概念的理解。  

## 27.2 实验要求  
在三台机器上, 分别部署一个broker，Zookeeper使用的是单独的集群，然后创建一个topic，启动模拟的生产者和消费者脚本，在生产者端向topic里写数据，在消费者端观察读取到的数据。  

## 27.3 实验原理  
### 27.3.1 Kafka简介  
Kafka是一种高吞吐量的分布式发布订阅消息系统，它可以处理消费者规模的网站中的所有动作流数据。它提供了类似于JMS的特性，但是在设计实现上完全不同，此外它并不是JMS规范的实现。**kafka对消息保存时根据Topic进行归类，发送消息者成为Producer,消息接受者成为Consumer,此外kafka集群有多个kafka实例组成，每个实例(server)成为broker**。无论是kafka集群，还是producer和consumer都依赖于zookeeper来保证系统可用性集群保存一些meta信息。如图所示:  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex27/1.png)  

一个Topic的多个partitions,被分布在kafka集群中的多个server上;每个server(kafka实例)负责partitions中消息的读写操作;此外kafka还可以配置partitions需要备份的个数(replicas),每个partition将会被备份到多台机器上,以提高可用性。  

基于replicated方案,那么就意味着需要对多个备份进行调度;**每个partition都有一个server为"leader";leader负责所有的读写操作,如果leader失效,那么将会有其他follower来接管(成为新的leader);follower只是单调的和leader跟进,同步消息即可**..由此可见作为leader的server承载了全部的请求压力,因此从集群的整体考虑,有多少个partitions就意味着有多少个"leader",kafka会将"leader"均衡的分散在每个实例上,来确保整体的性能稳定。  

**生产者**：Producer将消息发布到指定的Topic中,同时Producer也能决定将此消息归属于哪个partition;比如基于"round-robin"方式或者通过其他的一些算法等。  

**消费者**：本质上kafka只支持Topic.每个consumer属于一个consumer group;反过来说,每个group中可以有多个consumer.发送到Topic的消息,只会被订阅此Topic的每个group中的一个consumer消费。  

如果所有的consumer都具有相同的group,这种情况和queue模式很像;消息将会在consumers之间负载均衡。  
如果所有的consumer都具有不同的group,那这就是"发布-订阅";消息将会广播给所有的消费者。  

在kafka中,**一个partition中的消息只会被group中的一个consumer消费;每个group中consumer消息消费互相独立**;我们可以认为一个group是一个"订阅"者,一个Topic中的每个partions,只会被一个"订阅者"中的一个consumer消费,不过一个consumer可以消费多个partitions中的消息.kafka只能保证一个partition中的消息被某个consumer消费时,消息是顺序的.事实上,从Topic角度来说,消息仍不是有序的。  

kafka的设计原理决定,对于一个topic,同一个group中不能有多于partitions个数的consumer同时消费,否则将意味着某些consumer将无法得到消息。  

Guarantees
（1）发送到partitions中的消息将会按照它接收的顺序追加到日志中。  
（2）对于消费者而言,它们消费消息的顺序和日志中消息顺序一致。  
（3）如果Topic的"replicationfactor"为N,那么允许N-1个kafka实例失效。  

### 27.3.2 Kafka使用场景  
(1)Messaging  
对于一些常规的消息系统,kafka是个不错的选择;partitons/replication和容错,可以使kafka具有良好的扩展性和性能优势.不过到目前为止,我们应该很清楚认识到,kafka并没有提供JMS中的"事务性""消息传输担保(消息确认机制)""消息分组"等企业级特性;kafka只能使用作为"常规"的消息系统,在一定程度上,尚未确保消息的发送与接收绝对可靠(比如,消息重发,消息发送丢失等)。  

(2)Websit activity tracking  
kafka可以作为"网站活性跟踪"的最佳工具;可以将网页/用户操作等信息发送到kafka中.并实时监控,或者离线统计分析等。  

(3)Log Aggregation  
kafka的特性决定它非常适合作为"日志收集中心";application可以将操作日志"批量""异步"的发送到kafka集群中,而不是保存在本地或者DB中;kafka可以批量提交消息/压缩消息等,这对producer端而言,几乎感觉不到性能的开支.此时consumer端可以使hadoop等其他系统化的存储和分析系统。  

## 27.4 实验步骤  
本实验主要演示Kafka的安装，及简单使用，Kafka数据保存在Zookeeper上，所以该实验主要包含以下三个步骤。  

### 27.4.1 安装Zookeeper集群
这里我们直接使用zookeeper-storm集成集群，省略该步。  

### 27.4.2 安装Kafka集群  
[下载链接](http://kafka.apache.org/downloads)  
这里我们选择的版本是kafka_2.10-0.9.0.1.tgz.  

下载后上传至master节点，解压至/usr/local/kafka目录下。  

通过scp命令将传到另外两个节点:  
```
root@master:/usr/local# scp -r  kafka hadoop-slave1:/usr/local/
root@master:/usr/local# scp -r  kafka hadoop-slave2:/usr/local/
```  

三个节点分别进入安装目录，在config目录修改server.properties文件，修改内容如下:  

master:  
```
#broker.id
broker.id=1
#broker.port
port=9092
#host.name
host.name=master
#本地日志文件位置
log.dirs=/usr/local/kafka/logs
#Zookeeper地址
zookeeper.connect=master:2181,hadoop-slave1:2181,hadoop-slave2:2181
```

hadoop-slave1:  
```
#broker.id
broker.id=2
#broker.port
port=9092
#host.name
host.name=hadoop-slave1
#本地日志文件位置
log.dirs=/usr/local/kafka/logs
#Zookeeper地址
zookeeper.connect=master:2181,hadoop-slave1:2181,hadoop-slave2:2181
```

hadoop-slave2:  
```
#broker.id
broker.id=3
#broker.port
port=9092
#host.name
host.name=hadoop-slave2
#本地日志文件位置
log.dirs=/usr/local/kafka/logs
#Zookeeper地址
zookeeper.connect=master:2181,hadoop-slave1:2181,hadoop-slave2:2181
```

然后，启动Kafka，并验证Kafka功能:  

打开三个终端进入各个节点,进入安装目录下的bin目录，**三台机器上分别执行以下命令启动各自的Kafka服务**：  
```
root@master:/usr/local/kafka/bin# ./kafka-server-start.sh ../config/server.properties &
```  

看到  
```
[2018-08-07 03:56:19,966] INFO [Kafka Server 1], started (kafka.server.KafkaServer)
```
即成功启动，之后可以ctrl+c退出，通过jps命令可查看到kafka进程:  
```
root@master:/usr/local/kafka/bin# jps
262 QuorumPeerMain
395 Jps
319 Kafka
```  


在**master**上，执行以下命令创建topic：  
```
root@master:/usr/local/kafka/bin# ./kafka-topics.sh --create --zookeeper master:2181,hadoop-slave1:2181,hadoop-slave2:2181 --replication-factor 2 --partitions 2 --topic test
```  

在**slave1**上，执行以下命令启动模拟producer：（启动后不要退出终端)  
```
root@hadoop-slave1:/usr/local/kafka/bin# ./kafka-console-producer.sh --broker-list master:9092,hadoop-slave1:9092,hadoop-slave2:9092 --topic test
```  

在**slave2**上,执行以下命令启动模拟consumer：（启动后不要退出终端)  
```
root@hadoop-slave2:/usr/local/kafka/bin# ./kafka-console-consumer.sh --zookeeper master:2181,hadoop-slave1:2181,hadoop-slave2:2181 --topic test --from-beginning
```

### 27.4.3 验证消息推送  
在producer端(即hadoop-slave1)输入任意信息，然后观察consumer端(即hadoop-slave2)接收到的数据，如：  

producer:
```
root@hadoop-slave1:/usr/local/kafka/bin# ./kafka-console-producer.sh --broker-list master:9092,hadoop-slave1:9092,hadoop-slave2:9092 --topic test
This is Kafka producer
Hello,Kafka
test
```  

consumer:
```  
root@hadoop-slave2:/usr/local/kafka/bin# ./kafka-console-consumer.sh --zookeeper master:2181,hadoop-slave1:2181,hadoop-slave2:2181 --topic test --from-beginning
This is Kafka producer
Hello,Kafka
test
```

producer端输入的信息都会在consumer端接收。




