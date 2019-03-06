# 实验二十 部署ZooKeeper

## 20.1 实验目的
掌握ZooKeeper集群安装部署，加深对ZooKeeper相关概念的理解，熟练ZooKeeper的一些常用Shell命令。  

## 20.2 实验要求
部署三个节点的ZooKeeper集群，通过ZooKeeper客户端连接ZooKeeper集群，并用Shell命令练习创建目录，查询目录等。  

## 20.3 实验原理
ZooKeeper 分布式服务框架是 Apache Hadoop的一个子项目，它主要是用来解决分布式应用中经常遇到的一些数据管理问题，如：**统一命名服务、状态同步服务、集群管理、分布式应用配置项的管理等**。  

ZooKeeper是以**Fast Paxos算法**为基础的。  

ZooKeeper集群的初始化过程：集群中所有机器以投票的方式（少数服从多数）选取某一台机器作为**leader**(领导者)，其余机器作为**follower**(追随者)。如果集群中只有一台机器，那么就这台机器就是leader，没有follower。  

ZooKeeper集群与客户端的交互：客户端可以在任意情况下ZooKeeper集群中任意一台机器上进行读操作；但是写操作必须得到leader的同意后才能执行。  

ZooKeeper选取leader的核心算法思想：如果某服务器获得N/2 + 1票，则该服务器成为leader。N为集群中机器数量。为了避免出现两台服务器获得相同票数（N/2），应该**确保N为奇数**。因此构建ZooKeeper集群最少需要3台机器。  

## 20.4 实验步骤
本实验主要介绍ZooKeeper的部署，ZooKeeper一般部署奇数个节点，部署方法包主要含安装JDK、修改配置文件、启动测试三个步骤。  

这次实验在最新修改的spark集成镜像里直接部署zookeeper。

### 20.4.1 安装JDK
下载安装JDK。因为**ZooKeeper服务器在JVM上运行**。集成镜像里已装有，省略该步骤。

### 20.4.2 安装zookeeper
主机去官网下载zookeeper,这次实验选择的版本是**zookeeper-3.4.10**。解压在目录/usr/local/zookeeper下。  
```
root@master:/usr/local/mirror# tar -zxvf zookeeper-3.4.10.tar.gz
root@master:/usr/local/mirror# mv zookeeper-3.4.10 /usr/local/zookeeper
root@master:/usr/local/zookeeper# ls
LICENSE.txt           build.xml   ivy.xml          zookeeper-3.4.10.jar
NOTICE.txt            conf        ivysettings.xml  zookeeper-3.4.10.jar.asc
README.txt            contrib     lib              zookeeper-3.4.10.jar.md5
README_packaging.txt  dist-maven  recipes          zookeeper-3.4.10.jar.sha1
bin                   docs        src
```  

### 20.4.3 修改配置文件
进入/usr/local/zookeeper/conf目录下，将zoo_sample.cfg修改文件名为zoo.cfg,修改里面的一些配置内容:  
```
root@master:/usr/local/zookeeper/conf# cp zoo_sample.cfg zoo.cfg
root@master:/usr/local/zookeeper/conf# vim zoo.cfg 
```  

修改内容为:  
```
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial 
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
dataDir=/usr/local/zookeeper/data
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1
server.1=master:2888:3888
server.2=slave1:2888:3888
server.3=slave2:2888:3888
```

要修改的不多，就是指定dataDir路径跟添加最后的三个server.id,这个id(即1,2,3)很关键，后面会用上。  

创建**/usr/local/zookeeper/data**目录，在该目录下创建文件**myid**，写入内容id,我们在master里面操作，里面就写一个1，在slave1里就写2,slave2里就写3。
```  
root@master:/usr/local/zookeeper# mkdir data
root@master:/usr/local/zookeeper/data# vim myid
root@master:/usr/local/zookeeper/data# cat myid
1
```

这只是完成了master容器的zookeeper配置，通过scp命令将zookeeper整个目录传入slave1跟slave2容器并修改各自的myid文件为对应的id。
```
root@master:/usr/local# scp -r /usr/local/zookeeper slave1:/usr/local
root@master:/usr/local# scp -r /usr/local/zookeeper slave2:/usr/local
```

登录slave节点修改myid文件:  
```
root@master:/usr/local# ssh slave1
root@slave1:~# cd /usr/local/zookeeper/data
root@slave1:/usr/local/zookeeper/data# vim myid

root@slave1:/usr/local/zookeeper/data# ssh slave2
root@slave2:~# cd /usr/local/zookeeper/data
root@slave2:/usr/local/zookeeper/data# vim myid 
```  

### 20.4.4 启动zookeeper集群
分别在三个节点进入bin目录，启动ZooKeeper服务进程：  
```
root@master:/usr/local/zookeeper/bin# ./zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
root@master:/usr/local/zookeeper/bin# jps
1104 QuorumPeerMain
1132 Jps
```
jps命令看到QuorumPeerMain证明成功启动，在三个节点都做相同的启动操作。**三个节点都成功启动后，则可通过status查看各自的状态**。  
```
root@master:/usr/local/zookeeper/bin# ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: follower

root@slave1:/usr/local/zookeeper/bin# ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: leader

root@slave2:/usr/local/zookeeper/bin# ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: follower
```

可看到最终是slave1节点为leader。

## 20.5 基本操作  
在其中一台机器上执行客户端脚本,这里我们选择master节点:  
```
root@master:/usr/local/zookeeper/bin# ./zkCli.sh -server master:2181,slave1:2181,slave2:2181
```
后面出现一大串，成功进入客户端后可输入其他指令。

在客户端shell下执行创建目录命令：  
```
create /testZK ""
Created /testZK
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 1] ls /
[zookeeper, testZK]
```

向/testZk目录写数据：  
```
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 2] set /testZK 'aaa'
cZxid = 0x100000002
ctime = Fri Jul 27 07:59:30 UTC 2018
mZxid = 0x100000003
mtime = Fri Jul 27 08:02:03 UTC 2018
pZxid = 0x100000002
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0
```

读取/testZk目录数据：  
```
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 4] get /testZK
aaa
cZxid = 0x100000002
ctime = Fri Jul 27 07:59:30 UTC 2018
mZxid = 0x100000003
mtime = Fri Jul 27 08:02:03 UTC 2018
pZxid = 0x100000002
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0
```

删除/testZk目录：  
```
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 5] rmr /testZK
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 6] ls /
[zookeeper]
```  

在客户端shell下用quit命令退出客户端：  
```
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 7] quit
Quitting...
2018-07-27 08:03:50,654 [myid:] - INFO  [main:ZooKeeper@684] - Session: 0x364daa6c2520000 closed
2018-07-27 08:03:50,657 [myid:] - INFO  [main-EventThread:ClientCnxn$EventThread@519] - EventThread shut down for session: 0x364daa6c2520000
root@master:/usr/local/zookeeper/bin# 
```

