# 实验二 HDFS实验：部署HDFS
## 2.1  实验目的
1． 理解HDFS存在的原因；  
2． 理解HDFS体系架构；  
3． 理解master/slave架构；  
4． 理解为何配置文件里只需指定主服务、无需指定从服务；  
5． 理解为何需要客户端节点；  
6． 学会逐一启动HDFS和统一启动HDFS；  
7． 学会在HDFS中上传文件。

## 2.2 实验要求
要求实验结束时，已构建出以下HDFS集群：  
1． master上部署主服务NameNode；  
2． Slave1、2、3上部署从服务DataNode；  
3． 待集群搭建好后，还需在client上进行下述操作：在HDFS里新建目录；将某文件上传至HDFS里刚才新建的目录。

## 2.3 实验原理
### 2.3.1 分布式文件系统
**分布式文件系统（Distributed File System）**是指文件系统管理的物理存储资源不一定直接连接在本地节点上，而是通过计算机网络与节点相连。该系统架构于网络之上，势必会引入网络编程的复杂性，因此分布式文件系统比普通磁盘文件系统更为复杂。  

### 2.3.2 HDFS
HDFS（Hadoop Distributed File System）为大数据平台其它所有组件提供了基本的存储功能。它具有高容错、高可靠、可扩展、高吞吐率等特征，为大数据存储和处理提供了强大的底层存储架构。   

HDFS是一个主/从（master/slave）体系结构，从最终用户的角度来看，它就像传统的文件系统，可通过目录路径对文件执行CRUD操作。由于其分布式存储的性质，HDFS集群拥有一个NameNode和一些DataNodes，**NameNode**管理文件系统的元数据，**DataNode**存储实际的数据。  

HDFS开放文件系统的命名空间以便用户以文件形式存储数据，秉承“一次写入、多次读取”的原则。客户端通过NameNode和DataNodes的交互访问文件系统，联系NameNode以获取文件的元数据，而**真正的文件I/O操作是直接和DataNode进行交互的**。 

### 2.3.3 HDFS基本命令
HDFS基本命令格式如下：
``hadoop fs -cmd args``
其中，**cmd**为具体的操作，**args**为参数。
部分HDFS命令示例如下：
```
hadoop fs -mkdir /user/trunk          #建立目录/user/trunk
hadoop fs -ls /user                  #查看/user目录下的目录和文件
hadoop fs -lsr /user                 #递归查看/user目录下的目录和文件
hadoop fs -put test.txt /user/trunk      #上传test.txt文件至/user/trunk
hadoop fs -get /user/trunk/test.txt      #获取/user/trunk/test.txt文件
hadoop fs -cat /user/trunk/test.txt      #查看/user/trunk/test.txt文件内容
hadoop fs -tail /user/trunk/test.txt      #查看/user/trunk/test.txt文件的最后1000行
hadoop fs -rm /user/trunk/test.txt       #删除/user/trunk/test.txt文件
hadoop fs -help ls                   #查看ls命令的帮助文档
```

### 2.3.4 HDFS适用场景
HDFS 提供高吞吐量应用程序数据访问功能，适合带有大型数据集的应用程序，以下是一些常用的应用场景：  
**数据密集型并行计算**：数据量极大，但是计算相对简单的并行处理，如大规模Web信息搜索；
**计算密集型并行计算**：数据量相对不是很大，但是计算较为复杂的并行计算，如3D建模与渲染、气象预报和科学计算；数据密集与计算密集混合型的并行计算，如3D电影的渲染。

HDFS在使用过程中有以下限制：
**HDFS不适合大量小文件的存储**，因NameNode将文件系统的**元数据存放在内存中**，因此存储的文件数目受限于NameNode的内存大小；
**HDFS适用于高吞吐量，而不适合低时间延迟的访问**；
**流式读取的方式，不适合多用户写入一个文件（一个文件同时只能被一个客户端写），以及任意位置写入（不支持随机写）**；
**HDFS更加适合写入一次，读取多次的应用场景**。

## 2.4 实验步骤

demo2的hadoop集群，配置文件均已复制到各个节点，master节点上也有启动脚本可以直接一键启动HDFS，Yarn.
为方便学习文档中还是补充常规配置时的过程.

部署HDFS的步骤如下：  
1． 配置Hadoop的安装环境；  
2． 配置Hadoop的配置文件；  
3． 启动HDFS服务；  
4． 验证HDFS服务可用。

### 2.4.1 在master节点上确定存在hadoop安装目录
```
root@hadoop-master:~# find / -name hadoop
/usr/local/hadoop
/usr/local/hadoop/share/doc/hadoop
/usr/local/hadoop/share/hadoop
/usr/local/hadoop/share/hadoop/httpfs/tomcat/webapps/webhdfs/WEB-INF/classes/org/apache/hadoop
/usr/local/hadoop/share/hadoop/httpfs/tomcat/webapps/webhdfs/WEB-INF/classes/org/apache/hadoop/lib/service/hadoop
/usr/local/hadoop/bin/hadoop
/usr/local/hadoop/etc/hadoop
root@hadoop-master:~# cd /usr/local/hadoop
root@hadoop-master:/usr/local/hadoop# ls
LICENSE.txt  README.txt  etc      lib      logs  share
NOTICE.txt   bin         include  libexec  sbin
```

### 2.4.2 确认各节点之间可SSH免密登录
使用ssh工具登录到各个节点，执行命令ssh 主机名，确认每个均可SSH免密登录。**(demo2里创建了bridge连接各个容器，每个节点也各自生成了密钥，是可以通过ssh互通的)**
```
root@hadoop-master:/usr/local/hadoop# ssh hadoop-slave1
Warning: Permanently added 'hadoop-slave1,172.19.0.3' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 14.04.4 LTS (GNU/Linux 4.13.0-39-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
root@hadoop-slave1:~# 
```

### 2.4.3  修改HDFS配置文件

hadoop的配置文件都在**/usr/local/hadoop/etc/hadoop**目录下:
```
root@hadoop-master:/usr/local/hadoop/etc/hadoop# ls
capacity-scheduler.xml      httpfs-env.sh            mapred-env.sh
configuration.xsl           httpfs-log4j.properties  mapred-queues.xml.template
container-executor.cfg      httpfs-signature.secret  mapred-site.xml
core-site.xml               httpfs-site.xml          mapred-site.xml.template
hadoop-env.cmd              kms-acls.xml             slaves
hadoop-env.sh               kms-env.sh               ssl-client.xml.example
hadoop-metrics.properties   kms-log4j.properties     ssl-server.xml.example
hadoop-metrics2.properties  kms-site.xml             yarn-env.cmd
hadoop-policy.xml           log4j.properties         yarn-env.sh
hdfs-site.xml               mapred-env.cmd           yarn-site.xml
```

为了配置HDFS，我们需要修改两个配置文件：**hadoop-env.sh**和**core-site.xml**  

1.**设置JDK安装目录**  
编辑文件“/usr/local/hadoop/etc/hadoop/hadoop-env.sh”，找到如下一行：  
``export JAVA_HOME=${JAVA_HOME}``  
将这行内容修改为：  
``export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64``  
这里的**“/usr/lib/jvm/java-7-openjdk-amd64”**就是JDK安装位置，如果不同，请根据实际情况更改。  
  
这里我们演示一遍**demo2**中的操作(实际已经配置好，演示以便学习):  
(1)寻找jdk路径
```
root@hadoop-master:/usr/local/hadoop/etc/hadoop# find / -name java
/etc/alternatives/java
/etc/ssl/certs/java
/var/lib/dpkg/alternatives/java
/usr/share/java
/usr/bin/java
/usr/lib/jvm/java-7-openjdk-amd64/bin/java
/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
root@hadoop-master:/usr/local/hadoop/etc/hadoop# cd /usr/lib/jvm/java-7-openjdk-amd64/
root@hadoop-master:/usr/lib/jvm/java-7-openjdk-amd64# ls
ASSEMBLY_EXCEPTION  bin   include  lib  src.zip
THIRD_PARTY_README  docs  jre      man
```
**/usr/lib/jvm/java-7-openjdk-amd64** 即jdk路径
``vi hadoop-env.sh``  
(2)编辑hadoop-env.sh,修改为  
``export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64``

2.**指定HDFS主节点**
编辑文件**/usr/local/hadoop/etc/hadoop/core-site.xml**
``vi core-site.xml``
修改文件内容如下：
```xml
<?xml version="1.0"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoop-master:9000/</value>
    </property>
</configuration>
```
实际内容是指定namenode,即demo2里我们启动的**hadoop-master**容器。一般配置中需要将修改后的配置文件通过**scp命令**拷贝至集群每个节点，因为demo2里在启动容器时已经配置好相应的配置文件，这里就不再操作。

### 2.4.4 启动HDFS
demo2里由于已经完成各项配置,**start-hadoop.sh**可一键启动包括HDFS,yarn在内的各项进程。
```
root@hadoop-master:~# ls
hdfs  run-wordcount.sh  start-hadoop.sh
```

接下来的说明是常规配置时，在完成将修改后的配置文件拷贝至各节点后的操作:  
(1)在master节点上格式化主节点:  
``[root@master ~]# hdfs  namenode  -format``  
(2)配置slaves文件，将localhost修改为slave1~2：  
```
[root@master ~]# vi /usr/local/hadoop/etc/hadoop/slaves
hadoop-slave1
hadoop-slave2
```
slaves文件指定**datanode**,内容根据集群中slave节点的数量填上各个slave节点的主机名。
(3)统一启动HDFS：
```
root@hadoop-master:/usr/local/hadoop/sbin# ls
distribute-exclude.sh    start-all.cmd        stop-balancer.sh
hadoop-daemon.sh         start-all.sh         stop-dfs.cmd
hadoop-daemons.sh        start-balancer.sh    stop-dfs.sh
hdfs-config.cmd          start-dfs.cmd        stop-secure-dns.sh
hdfs-config.sh           start-dfs.sh         stop-yarn.cmd
httpfs.sh                start-secure-dns.sh  stop-yarn.sh
kms.sh                   start-yarn.cmd       yarn-daemon.sh
mr-jobhistory-daemon.sh  start-yarn.sh        yarn-daemons.sh
refresh-namenodes.sh     stop-all.cmd
slaves.sh                stop-all.sh
root@hadoop-master:/usr/local/hadoop/sbin# ./start-dfs.sh 
```

### 2.4.5 通过查看进程的方式验证HDFS启动成功
通过jps命令查看各节点是否启动相应服务：  
master:
```
root@hadoop-master:~# jps
374 SecondaryNameNode
173 NameNode
543 ResourceManager
1044 Jps
```
(看到NameNode,SecondaryNameNode,Jps即成功启动，有ResourceManager是因为一键启动脚本启动了yarn)

slave:
```
root@hadoop-slave1:~# jps
372 Jps
71 DataNode
182 NodeManager
```
(看到DataNode,Jps即成功启动，有NodeManager是因为一键启动脚本启动了yarn)

### 2.4.6 在master节点上尝试上传文件
在master节点上使用hadoop命令会报错
```
root@hadoop-master:~# hadoop fs -ls
-bash: hadoop: command not found
```
原因是没有配置环境变量,编辑**/etc/profile**配置环境变量(该配置也包括了对java Classpath的配置，下一个实验有讲）  
在文件末尾添加:
```xml
JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64/
export HADOOP_HOME=/usr/local/hadoop
export JRE_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64/jre
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/common/lib/*
export PATH=$PATH:$HADOOP_HOME/bin
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib:$HADOOP_HOME/lib/native"
```
修改后``source /etc/profile``即可正常使用hadoop命令

上传文件：
```
root@hadoop-master:~# ls
hdfs  input.txt  run-wordcount.sh  start-hadoop.sh
root@hadoop-master:~# cat input.txt 
test
root@hadoop-master:~# hadoop fs -put input.txt /
root@hadoop-master:~# hadoop fs -ls /
Found 1 items
-rw-r--r--   2 root supergroup          5 2018-06-23 05:22 /input.txt
root@hadoop-master:~# hadoop fs -cat /input.txt
test
```











