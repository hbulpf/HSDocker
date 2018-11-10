# 实验四  YARN实验：部署YARN集群

## 4.1 实验目的
了解什么是YARN框架，如何搭建YARN分布式集群，并能够使用YARN集群提交一些简单的任务，理解YARN作为Hadoop生态中的资源管理器的意义。

## 4.2 实验要求
搭建YARN集群，并使用YARN集群提交简单的任务。观察任务提交的之后的YARN的执行过程。

## 4.3 实验原理
### 4.3.1 YARN概述
YARN是一个资源管理、任务调度的框架，采用master/slave架构，主要包含**三大模块：ResourceManager（RM）、NodeManager（NM）、ApplicationMaster（AM）**。其中，**ResourceManager负责所有资源的监控、分配和管理，运行在主节点**； **NodeManager负责每一个节点的维护，运行在从节点**；ApplicationMaster负责每一个具体应用程序的调度和协调，只有在有任务正在执行时存在。对于所有的applications，RM拥有绝对的控制权和对资源的分配权。而每个AM则会和RM协商资源，同时和NodeManager通信来执行和监控task。几个模块之间的关系如图4-1所示：
![图4-1](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex4/image/1.png)

### 4.3.2 YARN运行流程
YARN运行流程如图：
![图4-2](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex4/image/2.png)

client向RM提交应用程序，其中包括启动该应用的ApplicationMaster的必须信息，例如ApplicationMaster程序、启动ApplicationMaster的命令、用户程序等。  

ResourceManager启动一个container用于运行ApplicationMaster。启动中的ApplicationMaster向ResourceManager注册自己，启动成功后与RM保持心跳。ApplicationMaster向ResourceManager发送请求，申请相应数目的container。

ResourceManager返回ApplicationMaster的申请的containers信息。申请成功的container，由ApplicationMaster进行初始化。container的启动信息初始化后，AM与对应的NodeManager通信，要求NM启动container。AM与NM保持心跳，从而对NM上运行的任务进行监控和管理。

container运行期间，ApplicationMaster对container进行监控。container通过RPC协议向对应的AM汇报自己的进度和状态等信息。应用运行期间，client直接与AM通信获取应用的状态、进度更新等信息。应用运行结束后，ApplicationMaster向ResourceManager注销自己，并允许属于它的container被收回。

## 4.4 实验步骤
该实验主要分为配置YARN的配置文件，启动YARN集群，向YARN几个简单的任务从而了解YARN工作的流程。

### 4.4.1 在master机上配置YARN
**(再次提醒，demo2已经自动完成配置，以下内容只是供学习，当没有配置的情况下该怎么做)**

指定YARN主节点，编辑文件/usr/local/hadoop/etc/hadoop/**yarn-site.xml**,添加以下内容：
```xml
<?xml version="1.0"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>hadoop-master</value>
    </property>
</configuration>
```
yarn-site.xml是YARN守护进程的配置文件。第一句配置了节点管理器运行的附加服务为mapreduce_shuffle，第三句配置了ResourceManager的主机名，只有这样才可以运行MapReduce程序。

完成配置后通过scp命令复制到各个slave节点即可。

### 4.4.2 统一启动YARN
确认已经配置Slaves文件，启动HDFS后，运行yarn启动脚本
``root@hadoop-master:/usr/local/hadoop/sbin# ./start-yarn.sh``

### 4.4.3 验证YARN启动成功
在各个节点通过jps命令查看YARN服务是否已启动。  
**master**:
```
root@hadoop-master:~# jps
374 SecondaryNameNode
2491 Jps
173 NameNode
543 ResourceManager
```
这表明在master节点成功启动ResourceManager，它负责整个集群的资源管理分配，是一个全局的资源管理系统。

**slave**:
```
root@hadoop-slave1:~# jps
71 DataNode
182 NodeManager
499 Jps
```
NodeManager是每个节点上的资源和任务管理器，它是管理这台机器的代理，负责该节点程序的运行，以及该节点资源的管理和监控。YARN集群每个节点都运行一个NodeManager。

### 4.4.4 查看Web界面
若是服务器或本地主机，只需要打开浏览器输入master的IP和端口号8080,即可在Web界面上看到YARN相关信息。在但里集群使用的是容器无法实现，所以我们可以使用端口映射：

```
ykk@ykk-TN15S:~/team/docker-hadoop/hadoop-cluster-docker$ sudo docker inspect hadoop-master | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.19.0.2",
```

先获取要的容器的IP，其他途径获取也可以

    sudo iptables -t nat -A DOCKER -p tcp --dport 50070 -j DNAT --to-destination 172.19.0.2:50070
    sudo iptables -t nat -A DOCKER -p tcp --dport 8088 -j DNAT --to-destination 172.19.0.2:8088

映射哪个端口就指定哪个,之后打开浏览器输入localhost:8088即可看到Web界面：

### 4.4.5 提交DistributedShell任务
distributedshell，他可以看做YARN编程中的“hello world”，它的主要功能是并行执行用户提供的shell命令或者shell脚本。**-jar指定了包含ApplicationMaster的jar文件**，**-shell_command指定了需要被ApplicationMaster执行的Shell命令**。

```
[root@hadoop-master]# /usr/local/hadoop/bin/yarn org.apache.hadoop.yarn.applications.distributedshell.Client  -jar /usr/local/hadoop/share/hadoop/yarn/hadoop-yarn-applications-distributedshell-2.7.2.jar -shell_command  uptime
```

### 4.4.6 提交MapReduce任务
(1)指定在YARN上运行MapReduce任务
**(以下内容仅供学习，不必操作)**
编辑/usr/local/hadoop/etc/hadoop/**mapred-site.xml**，复制以下内容：
```xml
<?xml version="1.0"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```
最后，将master机的“/usr/local/hadoop/etc/hadoop/mapred-site.xml”文件拷贝到各个Slave节点，重启集群。

(2)提交PI Estimator任务
/usr/local/hadoop/share/hadoop/mapreduce目录下有各个已经写好的测试jar包
```
root@hadoop-master:/usr/local/hadoop/share/hadoop/mapreduce# ls
hadoop-mapreduce-client-app-2.7.2.jar
hadoop-mapreduce-client-common-2.7.2.jar
hadoop-mapreduce-client-core-2.7.2.jar
hadoop-mapreduce-client-hs-2.7.2.jar
hadoop-mapreduce-client-hs-plugins-2.7.2.jar
hadoop-mapreduce-client-jobclient-2.7.2-tests.jar
hadoop-mapreduce-client-jobclient-2.7.2.jar
hadoop-mapreduce-client-shuffle-2.7.2.jar
hadoop-mapreduce-examples-2.7.2.jar
lib
lib-examples
sources
root@hadoop-master:/usr/local/hadoop/share/hadoop/mapreduce# hadoop jar hadoop-mapreduce-examples-2.7.2.jar pi 2 10
```
命令最后两个两个参数的含义：第一个参数是指要运行map的次数，这里是2次；第二个参数是指每个map任务，取样的个数；而两数相乘即为总的取样数。Pi Estimator使用Monte Carlo方法计算Pi值的，Monte Carlo方法自行百度。

## 4.5 实验结果
(1)yarn启动之后在localhost:8080的web界面上能看到的界面:
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex4/image/3.png)

(2)提交PI Estinmator后终端的内容：
```
root@hadoop-master:/usr/local/hadoop/share/hadoop/mapreduce# hadoop jar hadoop-mapreduce-examples-2.7.2.jar pi 2 10
Number of Maps  = 2
Samples per Map = 10
Wrote input for Map #0
Wrote input for Map #1
Starting Job
18/06/23 09:45:57 INFO client.RMProxy: Connecting to ResourceManager at hadoop-master/172.19.0.2:8032
18/06/23 09:45:58 INFO input.FileInputFormat: Total input paths to process : 2
18/06/23 09:45:58 INFO mapreduce.JobSubmitter: number of splits:2
18/06/23 09:45:58 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1529724645512_0002
18/06/23 09:45:58 INFO impl.YarnClientImpl: Submitted application application_1529724645512_0002
18/06/23 09:45:58 INFO mapreduce.Job: The url to track the job: http://hadoop-master:8088/proxy/application_1529724645512_0002/
18/06/23 09:45:58 INFO mapreduce.Job: Running job: job_1529724645512_0002
18/06/23 09:46:03 INFO mapreduce.Job: Job job_1529724645512_0002 running in uber mode : false
18/06/23 09:46:03 INFO mapreduce.Job:  map 0% reduce 0%
18/06/23 09:46:08 INFO mapreduce.Job:  map 100% reduce 0%
18/06/23 09:46:13 INFO mapreduce.Job:  map 100% reduce 100%
18/06/23 09:46:14 INFO mapreduce.Job: Job job_1529724645512_0002 completed successfully
18/06/23 09:46:15 INFO mapreduce.Job: Counters: 49
	File System Counters
		FILE: Number of bytes read=50
		FILE: Number of bytes written=353313
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=536
		HDFS: Number of bytes written=215
		HDFS: Number of read operations=11
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=3
	Job Counters 
		Launched map tasks=2
		Launched reduce tasks=1
		Data-local map tasks=2
		Total time spent by all maps in occupied slots (ms)=5722
		Total time spent by all reduces in occupied slots (ms)=2404
		Total time spent by all map tasks (ms)=5722
		Total time spent by all reduce tasks (ms)=2404
		Total vcore-milliseconds taken by all map tasks=5722
		Total vcore-milliseconds taken by all reduce tasks=2404
		Total megabyte-milliseconds taken by all map tasks=5859328
		Total megabyte-milliseconds taken by all reduce tasks=2461696
	Map-Reduce Framework
		Map input records=2
		Map output records=4
		Map output bytes=36
		Map output materialized bytes=56
		Input split bytes=300
		Combine input records=0
		Combine output records=0
		Reduce input groups=2
		Reduce shuffle bytes=56
		Reduce input records=4
		Reduce output records=0
		Spilled Records=8
		Shuffled Maps =2
		Failed Shuffles=0
		Merged Map outputs=2
		GC time elapsed (ms)=48
		CPU time spent (ms)=1230
		Physical memory (bytes) snapshot=840351744
		Virtual memory (bytes) snapshot=2682146816
		Total committed heap usage (bytes)=559415296
	Shuffle Errors
		BAD_ID=0
		CONNECTION=0
		IO_ERROR=0
		WRONG_LENGTH=0
		WRONG_MAP=0
		WRONG_REDUCE=0
	File Input Format Counters 
		Bytes Read=236
	File Output Format Counters 
		Bytes Written=97
Job Finished in 17.244 seconds
Estimated value of Pi is 3.80000000000000000000
```










