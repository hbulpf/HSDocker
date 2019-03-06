# 实验二十二　部署HBase

## 22.1 实验目的
1.掌握HBase基础简介及体系架构;  
2.掌握HBase集群安装部署及HBase Shell的一些常用命令的使用;  
3.了解HBase和HDFS及Zookeeper之间的关系。  

## 22.2 实验要求  
1.巩固学习下实验一、实验二、实验二十;  
2.部署一个主节点，三个子节点的HBase集群，并引用外部Zookeeper;  
3.进入HBase Shell通过命令练习创建表、插入数据及查询等命令。  

## 22.3 实验原理  
简介：**HBase是基于Hadoop的开源分布式数据库**，它以Google的BigTable为原型，设计并实现了具有高可靠性、高性能、列存储、可伸缩、实时读写的分布式数据库系统，它是基于列而不是基于行的模式，适合存储非结构化数据。  

体系结构：**HBase是一个分布式的数据库，使用Zookeeper管理集群，使用HDFS作为底层存储**，它**由HMaster和HRegionServer组成**，遵从主从服务器架构。HBase将逻辑上的表划分成多个数据块即HRegion，存储在HRegionServer中。HMaster负责管理所有的HRegionServer，它本身并不存储任何数据，而只是存储数据到HRegionServer的映射关系(元数据)。HBase的基本架构如图22-1所示：  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex22/1.jpg)  

## 22.4 实验步骤  
HBase依赖于HDFS和Zookeeper, 这次实验直接使用spark集成集群安装HBase。

### 22.4.1 启动集群  
```
ykk@ykk-TN15S:~/team/docker-hadoop/hadoop-cluster-docker$ ./start-container.sh 
[sudo] password for ykk: 
start master container...
start hadoop-slave1 container...
start hadoop-slave2 container...

root@master:~# ./start-hadoop.sh 
```  

### 22.4.2 安装部署HBase
本次实验下载的HBase版本是1.2.6，[下载链接](http://archive.apache.org/dist/hbase/)  

解压tar包至目录/usr/local/hbase:  
```
root@master:~# tar -zxvf hbase-1.2.6-bin.tar.gz
root@master:~# mv hbase-1.2.6 /usr/local/
```

添加环境变量: vi /etc/profile
```
export HBASE_HOME=/usr/local/hbase
export PATH=$PATH:$HBASE_HOME/bin
```

修改hosts文件: vi /etc/hosts:  
```
172.19.0.3      hadoop-slave1
172.19.0.4      hadoop-slave2
```  
末尾添加,ip根据实际情况决定。

**修改配置文件，进入/usr/local/hbase/conf目录**: 

(1)**hbase-env.sh**:
```
export JAVA_HOME=/usr/local/java

export HBASE_MANAGES_ZK=true
```  

找到JAVA_HOME和HBASE_MANAGES_ZK,**先取消注释#**,再添加所需要的值。**HBASE_MANAGES_ZK=true**即为使用HBase自带的Zookeeper，也可以自己安装Zookeeper，然后设该值为false。  

(2)**hbase-site.xml**:  
```xml
<configuration>
 <property>
  <name>hbase.rootdir</name>
  <value>hdfs://master:9000/hbase</value>
  <!-- 端口要和Hadoop的fs.defaultFS端口一致-->
 </property>
 <property>
  <name>hbase.cluster.distributed</name>
  <value>true</value>
   <!-- 是否分布式部署 -->
 </property>
 <property>
  <name>hbase.zookeeper.quorum</name>
  <value>master,hadoop-slave1,hadoop-slave2</value>
  <!-- 指定的主机均会启动Zookeeper的进程 -->
 </property>
  <name>hbase.tmp.dir</name>
  <value>/usr/local/hbase/data/tmp</value>
  <!--zookooper配置、日志等的存储位置,会自动创建 -->
 </property>
</configuration>
```  

(3)**regionservers**:  去掉localhost,添加slave节点主机名
```
hadoop-slave1
hadoop-slave2
```

通过scp命令将hbase传至hadoop-slave1和hadoop-slave2节点:  
```
root@master:~# scp -r /usr/local/hbase hadoop-slave1:/usr/local/
root@master:~# scp -r /usr/local/hbase hadoop-slave2:/usr/local/
```

## 22.4.3 启动HBase:  
进入/usr/local/hbase/bin目录,**启动脚本start-hbase.sh**
```
root@master:/usr/local/hbase/bin# ./start-hbase.sh 
hadoop-slave2: Warning: Permanently added 'hadoop-slave2,172.19.0.4' (ECDSA) to the list of known hosts.
master: Warning: Permanently added 'master,172.19.0.2' (ECDSA) to the list of known hosts.
hadoop-slave1: Warning: Permanently added 'hadoop-slave1,172.19.0.3' (ECDSA) to the list of known hosts.
master: starting zookeeper, logging to /usr/local/hbase/bin/../logs/hbase-root-zookeeper-master.out
hadoop-slave2: starting zookeeper, logging to /usr/local/hbase/bin/../logs/hbase-root-zookeeper-hadoop-slave2.out
hadoop-slave1: starting zookeeper, logging to /usr/local/hbase/bin/../logs/hbase-root-zookeeper-hadoop-slave1.out
starting master, logging to /usr/local/hbase/logs/hbase-root-master-master.out
hadoop-slave2: Warning: Permanently added 'hadoop-slave2,172.19.0.4' (ECDSA) to the list of known hosts.
hadoop-slave1: Warning: Permanently added 'hadoop-slave1,172.19.0.3' (ECDSA) to the list of known hosts.
hadoop-slave1: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-hadoop-slave1.out
hadoop-slave2: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-hadoop-slave2.out
```  

通过jps命令查看是否成功启动:  

对于master节点:  
```
root@master:/usr/local/hbase/bin# jps
4798 HMaster
4720 HQuorumPeer
175 NameNode
545 ResourceManager
5056 Jps
376 SecondaryNameNode
```
可看到成功启动HMaster和HQuorumPeer  

slave节点:  
```
root@hadoop-slave1:~# jps
1356 HQuorumPeer
1468 HRegionServer
72 DataNode
1689 Jps
183 NodeManager
```
可看到成功启动HRegionServer和HQuorumPeer  


打开主机浏览器,master节点的ip为172.19.0.2,输入**172.19.0.2:16010**即可进入HBase web界面:  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex22/Screenshot%20from%202018-07-30%2011-17-33.png)  


### 22.4.4 HBase shell  
安装完成后，我们可进入hbase shell测试一些简单命令:  
```
root@master:/usr/local/hbase/bin# ./hbase shell
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/local/hbase/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/local/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
HBase Shell; enter 'help<RETURN>' for list of supported commands.
Type "exit<RETURN>" to leave the HBase Shell
Version 1.2.6, rUnknown, Mon May 29 02:25:32 CDT 2017

hbase(main):001:0> 
```  

在尝试创建表时:  
```
hbase(main):002:0> create 'testhbase' , 'f1' 

ERROR: org.apache.hadoop.hbase.PleaseHoldException: Master is initializing
	at org.apache.hadoop.hbase.master.HMaster.checkInitialized(HMaster.java:2379)
	at org.apache.hadoop.hbase.master.HMaster.checkNamespaceManagerReady(HMaster.java:2384)
	at org.apache.hadoop.hbase.master.HMaster.ensureNamespaceExists(HMaster.java:2593)
	at org.apache.hadoop.hbase.master.HMaster.createTable(HMaster.java:1536)
	at org.apache.hadoop.hbase.master.MasterRpcServices.createTable(MasterRpcServices.java:463)
	at org.apache.hadoop.hbase.protobuf.generated.MasterProtos$MasterService$2.callBlockingMethod(MasterProtos.java:55682)
	at org.apache.hadoop.hbase.ipc.RpcServer.call(RpcServer.java:2196)
	at org.apache.hadoop.hbase.ipc.CallRunner.run(CallRunner.java:112)
	at org.apache.hadoop.hbase.ipc.RpcExecutor.consumerLoop(RpcExecutor.java:133)
	at org.apache.hadoop.hbase.ipc.RpcExecutor$1.run(RpcExecutor.java:108)
	at java.lang.Thread.run(Thread.java:745)
```
这时会报Master is initializing的错误，网上查了很久的解决办法，最后尝试修改**/etc/hosts**，指定对主机的映射解决问题（添加步骤已补充在前面)
```
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.19.0.2      master
172.19.0.3      hadoop-slave1
172.19.0.4      hadoop-slave2
```

创建表:  
```
hbase(main):001:0> create 'testhbase' , 'f1' 
0 row(s) in 2.5730 seconds

=> Hbase::Table - testhbase
```

查询所有表名:  
```
hbase(main):002:0> list
TABLE                                                                                                                         
testhbase                                                                                                                     
1 row(s) in 0.0140 seconds

=> ["testhbase"]
```  

查看表结构信息:  
```
hbase(main):002:0> describe 'testhbase'
Table testhbase is ENABLED                                                                                                    
testhbase                                                                                                                     
COLUMN FAMILIES DESCRIPTION                                                                                                   
{NAME => 'f1', DATA_BLOCK_ENCODING => 'NONE', BLOOMFILTER => 'ROW', REPLICATION_SCOPE => '0', VERSIONS => '1', COMPRESSION => 'NONE', MIN_VERSIONS => '0', TTL => 'FOREVER', KEEP_DELETED_CELLS => 'FALSE', BLOCKSIZE => '65536', IN_MEMORY => 'false', BLOCKCACHE => 'true'}                                                                                                             
1 row(s) in 0.0990 seconds
```  

在shell里插入数据:  
```
hbase(main):003:0> put 'testhbase', '001', 'f1:name', 'aaa'
0 row(s) in 0.0750 seconds
```  

在shell里查询:  
```
hbase(main):004:0> scan 'testhbase'
ROW                              COLUMN+CELL                                                                                  
 001                             column=f1:name, timestamp=1532938446750, value=aaa                                           
1 row(s) in 0.0250 seconds
```  

删除表，先disable再drop:  
```
hbase(main):005:0> disable 'testhbase'
0 row(s) in 4.3880 seconds

hbase(main):006:0> drop 'testhbase'
0 row(s) in 2.3560 seconds

hbase(main):007:0> list
TABLE                                                                                                                         
0 row(s) in 0.0070 seconds

=> []
```












