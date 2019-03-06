# 实验二十五 实时WordCountTopology

## 25.1 实验目的
掌握如何用Java代码来实现Storm任务的拓扑，掌握一个拓扑中Spout和Bolt的关系及如何组织它们之间的关系，掌握如何将Storm任务提交到集群。  

## 25.2 实验要求
编写一个Storm拓扑，**一个Spout每个一秒钟随机生成一个单词并发射给Bolt，Bolt统计接收到的每个单词出现的频率并每隔一秒钟实时打印一次统计结果**，最后将任务提交到集群运行，并通过日志查看任务运行结果。  

## 25.3 实验原理  
Storm集群和Hadoop集群表面上看很类似。但是Hadoop上运行的是MapReduce jobs，而在Storm上运行的是拓扑（topology），这两者之间是非常不一样的。一个关键的区别是：一个MapReduce job最终会结束， 而一个topology永远会运行（除非你手动kill掉）。  

### 25.3.1 Topologies  
**一个topology是spouts和bolts组成的图**，通过stream groupings将图中的spouts和bolts连接起来,如图所示:  
![图]()  

一个topology会一直运行直到你手动kill掉，Storm自动重新分配执行失败的任务， 并且Storm可以保证你不会有数据丢失（如果开启了高可靠性的话）。如果一些机器意外停机它上面的所有任务会被转移到其他机器上。  

运行一个topology很简单。首先，把你所有的代码以及所依赖的jar打进一个jar包。然后运行类似下面的这个命令:  
`storm jar all-my-code.jar backtype.storm.MyTopology arg1 arg2`  
这个命令会运行主类: backtype.strom.MyTopology, 参数是arg1, arg2。这个类的main函数定义这个topology并且把它提交给Nimbus。storm jar负责连接到Nimbus并且上传jar包。  

Topology的定义是一个Thrift结构，并且Nimbus就是一个Thrift服务，你可以提交由任何语言创建的topology。上面的方面是用JVM-based语言提交的最简单的方法。  

### 25.3.2 Spouts  
**消息源spout是Storm里面一个topology里面的消息生产者**。一般来说消息源会从一个外部源读取数据并且向topology里面发出消息：tuple。Spout可以是可靠的也可以是不可靠的。如果这个tuple没有被storm成功处理，可靠的消息源spouts可以重新发射一个tuple， 但是不可靠的消息源spouts一旦发出一个tuple就不能重发了。  

消息源可以发射多条消息流stream。使用OutputFieldsDeclarer.declareStream来定义多个stream，然后使用SpoutOutputCollector来发射指定的stream。  

**Spout类里面最重要的方法是nextTuple**。要么发射一个新的tuple到topology里面或者简单的返回如果已经没有新的tuple。要注意的是nextTuple方法不能阻塞，因为storm在同一个线程上面调用所有消息源spout的方法。  

**另外两个比较重要的spout方法是ack和fail。storm在检测到一个tuple被整个topology成功处理的时候调用ack，否则调用fail。storm只对可靠的spout调用ack和fail**。  

### 25.3.3 Bolts
**所有的消息处理逻辑被封装在bolts里面。Bolts可以做很多事情：过滤，聚合，查询数据库等等**。  

Bolts可以简单的做消息流的传递。复杂的消息流处理往往需要很多步骤，从而也就需要经过很多bolts。比如算出一堆图片里面被转发最多的图片就至少需要两步：第一步算出每个图片的转发数量。第二步找出转发最多的前10个图片。(如果要把这个过程做得更具有扩展性那么可能需要更多的步骤)。  

Bolts可以发射多条消息流，使用OutputFieldsDeclarer.declareStream定义stream，使用OutputCollector.emit来选择要发射的stream。  

**Bolts的主要方法是execute, 它以一个tuple作为输入，bolts使用OutputCollector来发射tuple，bolts必须要为它处理的每一个tuple调用OutputCollector的ack方法，以通知Storm这个tuple被处理完成了，从而通知这个tuple的发射者spouts**。一般的流程是：bolts处理一个输入tuple, 发射0个或者多个tuple,然后调用ack通知storm自己已经处理过这个tuple了。storm提供了一个IBasicBolt会自动调用ack。  

## 25.4 实验步骤  
本实验主要演示一个完整的Storm拓扑编码过程，主要包含Spout、Bolt和构建Topology几个步骤。  

首先，启动Storm集群，其次，将Storm安装包的lib目录内如下jar包导入到开发工具:  
```
asm-5.0.3.jar  
clojure-1.7.0.jar  
disruptor-3.3.2.jar  
kryo-3.0.3.jar  
log4j-api-2.8.jar  
log4j-core-2.8.jar  
log4j-over-slf4j-1.6.6.jar  
log4j-slf4j-impl-2.8.jar  
minlog-1.3.0.jar  
reflectasm-1.10.1.jar  
servlet-api-2.5.jar  
slf4j-api-1.7.21.jar  
storm-core-1.1.0.jar
```  
这里使用IDEA编写代码，导入jar包前面的实验有提过，创建项目wordCount-Storm

然后，编写代码，实现一个完整的Topology，内容如下:  

Spout随机发送单词，代码实现:  
```java
package cproc.word;

import java.util.Map;
import java.util.Random;
import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;
import org.apache.storm.utils.Utils;

public class WordReaderSpout extends BaseRichSpout{
    private SpoutOutputCollector collector;
    @Override
    public void open(Map conf, TopologyContext context, SpoutOutputCollector collector){
        this.collector = collector;
    }
    @Override
    public void nextTuple() {
        Utils.sleep(1000);
        final String[] words = new String[] {"nathan", "mike", "jackson", "golda", "bertels"};
        Random rand = new Random();
        String word = words[rand.nextInt(words.length)];
        collector.emit(new Values(word));
    }
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }
}
```  

Bolt单词计数，并每隔一秒打印一次，代码实现:  
```java
package cproc.word;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.BasicOutputCollector;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseBasicBolt;
import org.apache.storm.tuple.Tuple;

public class WordCounterBolt extends BaseBasicBolt{
    private static final long serialVersionUID = 5683648523524179434L;
    private HashMap<String, Integer> counters = new HashMap<String, Integer>();
    private volatile boolean edit = false;
    @Override
    public void prepare(Map stormConf, TopologyContext context) {
        new Thread(new Runnable() {
            public void run() {
                while (true) {
                    if (edit) {
                        for (Entry<String, Integer> entry : counters.entrySet())
                        {
                            System.out.println(entry.getKey() + " : " + entry.getValue());
                        }
                        edit = false;
                    }
                    try{
                        Thread.sleep(1000);
                    }catch (InterruptedException e){
                        e.printStackTrace();
                    }
                }
            }
        }).start();
    }

    @Override
    public void execute(Tuple input, BasicOutputCollector collector) {
        String str = input.getString(0);
        if (!counters.containsKey(str)) {
            counters.put(str, 1);
        }else{
            Integer c = counters.get(str) + 1;
            counters.put(str, c);
        }
        edit=true;
    }
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {

    }
}
```

构建Topology并提交到集群主函数，代码实现:  
```java
package cproc.word;

import org.apache.storm.Config;
import org.apache.storm.StormSubmitter;
import org.apache.storm.generated.AlreadyAliveException;
import org.apache.storm.generated.AuthorizationException;
import org.apache.storm.generated.InvalidTopologyException;
import org.apache.storm.topology.TopologyBuilder;

public class WordCountTopo {
    public static void main(String[] args)throws Exception{
        TopologyBuilder builder = new TopologyBuilder();
        builder.setSpout("word-reader", new WordReaderSpout());
        builder.setBolt("word-counter", new WordCounterBolt()).shuffleGrouping("word-reader");
        Config conf = new Config();
        StormSubmitter.submitTopologyWithProgressBar("wordCount", conf,builder.createTopology());
    }
}
```

完整项目如图:  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex25/Screenshot%20from%202018-08-03%2015-27-40.png)  

然后，将Storm代码打成wordCount-Storm.jar(打包的时候不要包含导入的任何jar，不然会报错的，将无法运行，即：wordCount-Storm.jar中只包含上面三个类的代码)上传到主节点的**/usr/local/storm/bin目录下**，在主节点进入Storm安装目录的bin下面用以下命令提交任务：  
``./storm jar wordCount-Storm.jar cproc.word.WordCountTopo wordCount`

使用以下命令结束storm任务:  
``./storm kill wordCount `

## 25.5 实验结果  
提交任务:  
```
root@master:/usr/local/storm/bin# ./storm jar wordCount-Storm.jar cproc.word.WordCountTopo wordCount
Running: /usr/local/java/bin/java -client -Ddaemon.name= -Dstorm.options= -Dstorm.home=/usr/local/storm -Dstorm.log.dir=/usr/local/storm/logs -Djava.library.path=/usr/local/lib:/opt/local/lib:/usr/lib -Dstorm.conf.file= -cp /usr/local/storm/lib/ring-cors-0.1.5.jar:/usr/local/storm/lib/minlog-1.3.0.jar:/usr/local/storm/lib/servlet-api-2.5.jar:/usr/local/storm/lib/reflectasm-1.10.1.jar:/usr/local/storm/lib/storm-core-1.1.0.jar:/usr/local/storm/lib/log4j-slf4j-impl-2.8.jar:/usr/local/storm/lib/storm-rename-hack-1.1.0.jar:/usr/local/storm/lib/log4j-api-2.8.jar:/usr/local/storm/lib/clojure-1.7.0.jar:/usr/local/storm/lib/asm-5.0.3.jar:/usr/local/storm/lib/log4j-over-slf4j-1.6.6.jar:/usr/local/storm/lib/slf4j-api-1.7.21.jar:/usr/local/storm/lib/kryo-3.0.3.jar:/usr/local/storm/lib/objenesis-2.1.jar:/usr/local/storm/lib/disruptor-3.3.2.jar:/usr/local/storm/lib/log4j-core-2.8.jar:wordCount-Storm.jar:/usr/local/storm/conf:/usr/local/storm/bin -Dstorm.jar=wordCount-Storm.jar -Dstorm.dependency.jars= -Dstorm.dependency.artifacts={} cproc.word.WordCountTopo wordCount
438  [main] INFO  o.a.s.StormSubmitter - Generated ZooKeeper secret payload for MD5-digest: -8414966403771477221:-7407907154665919134
522  [main] INFO  o.a.s.u.NimbusClient - Found leader nimbus : master:6627
543  [main] INFO  o.a.s.s.a.AuthUtils - Got AutoCreds []
545  [main] INFO  o.a.s.u.NimbusClient - Found leader nimbus : master:6627
563  [main] INFO  o.a.s.StormSubmitter - Uploading dependencies - jars...
565  [main] INFO  o.a.s.StormSubmitter - Uploading dependencies - artifacts...
566  [main] INFO  o.a.s.StormSubmitter - Dependency Blob keys - jars : [] / artifacts : []
574  [main] INFO  o.a.s.StormSubmitter - Uploading topology jar wordCount-Storm.jar to assigned location: /usr/local/storm/storm-local/nimbus/inbox/stormjar-d39d04da-4d01-41c8-9d72-3762d0bd76f8.jar
Start uploading file 'wordCount-Storm.jar' to '/usr/local/storm/storm-local/nimbus/inbox/stormjar-d39d04da-4d01-41c8-9d72-3762d0bd76f8.jar' (4888 bytes)
[==================================================] 4888 / 4888
File 'wordCount-Storm.jar' uploaded to '/usr/local/storm/storm-local/nimbus/inbox/stormjar-d39d04da-4d01-41c8-9d72-3762d0bd76f8.jar' (4888 bytes)
593  [main] INFO  o.a.s.StormSubmitter - Successfully uploaded topology jar to assigned location: /usr/local/storm/storm-local/nimbus/inbox/stormjar-d39d04da-4d01-41c8-9d72-3762d0bd76f8.jar
593  [main] INFO  o.a.s.StormSubmitter - Submitting topology wordCount in distributed mode with conf {"storm.zookeeper.topology.auth.scheme":"digest","storm.zookeeper.topology.auth.payload":"-8414966403771477221:-7407907154665919134"}
1571 [main] INFO  o.a.s.StormSubmitter - Finished submitting topology: wordCount
```

结束任务:  
```
root@master:/usr/local/storm/bin# ./storm kill wordCount           
Running: /usr/local/java/bin/java -client -Ddaemon.name= -Dstorm.options= -Dstorm.home=/usr/local/storm -Dstorm.log.dir=/usr/local/storm/logs -Djava.library.path=/usr/local/lib:/opt/local/lib:/usr/lib -Dstorm.conf.file= -cp /usr/local/storm/lib/ring-cors-0.1.5.jar:/usr/local/storm/lib/minlog-1.3.0.jar:/usr/local/storm/lib/servlet-api-2.5.jar:/usr/local/storm/lib/reflectasm-1.10.1.jar:/usr/local/storm/lib/storm-core-1.1.0.jar:/usr/local/storm/lib/log4j-slf4j-impl-2.8.jar:/usr/local/storm/lib/storm-rename-hack-1.1.0.jar:/usr/local/storm/lib/log4j-api-2.8.jar:/usr/local/storm/lib/clojure-1.7.0.jar:/usr/local/storm/lib/asm-5.0.3.jar:/usr/local/storm/lib/log4j-over-slf4j-1.6.6.jar:/usr/local/storm/lib/slf4j-api-1.7.21.jar:/usr/local/storm/lib/kryo-3.0.3.jar:/usr/local/storm/lib/objenesis-2.1.jar:/usr/local/storm/lib/disruptor-3.3.2.jar:/usr/local/storm/lib/log4j-core-2.8.jar:/usr/local/storm/conf:/usr/local/storm/bin org.apache.storm.command.kill_topology wordCount
1609 [main] INFO  o.a.s.u.NimbusClient - Found leader nimbus : master:6627
1689 [main] INFO  o.a.s.c.kill-topology - Killed topology: wordCount
```  

Storm任务执行时，可以查看Storm 日志文件，日志里面打印了统计的单词结果，**运行日志保存在worker.log里，该文件只存在于从节点**，进入从节点的**/usr/local/storm/logs/workers-artifacts/wordCount-1-1533279993/6700**目录:  
```
root@slave1:/usr/local/storm/logs/workers-artifacts/wordCount-1-1533279993/6700# ls
gc.log.0.current  worker.log  worker.log.err  worker.log.metrics  worker.log.out  worker.pid  worker.yaml
root@slave1:/usr/local/storm/logs/workers-artifacts/wordCount-1-1533279993/6700# cat worker.log
```  

以下是部分结果:  
```
2018-08-03 07:07:41.366 STDIO Thread-15 [INFO] golda : 17
2018-08-03 07:07:41.366 STDIO Thread-15 [INFO] bertels : 13
2018-08-03 07:07:42.367 STDIO Thread-15 [INFO] jackson : 5
2018-08-03 07:07:42.367 STDIO Thread-15 [INFO] mike : 9
2018-08-03 07:07:42.370 STDIO Thread-15 [INFO] nathan : 11
2018-08-03 07:07:42.370 STDIO Thread-15 [INFO] golda : 17
2018-08-03 07:07:42.370 STDIO Thread-15 [INFO] bertels : 14
2018-08-03 07:07:43.371 STDIO Thread-15 [INFO] jackson : 5
2018-08-03 07:07:43.371 STDIO Thread-15 [INFO] mike : 9
2018-08-03 07:07:43.371 STDIO Thread-15 [INFO] nathan : 11
2018-08-03 07:07:43.371 STDIO Thread-15 [INFO] golda : 17
2018-08-03 07:07:43.371 STDIO Thread-15 [INFO] bertels : 15
2018-08-03 07:07:44.372 STDIO Thread-15 [INFO] jackson : 5
2018-08-03 07:07:44.372 STDIO Thread-15 [INFO] mike : 10
2018-08-03 07:07:44.372 STDIO Thread-15 [INFO] nathan : 11
2018-08-03 07:07:44.373 STDIO Thread-15 [INFO] golda : 17
2018-08-03 07:07:44.373 STDIO Thread-15 [INFO] bertels : 15
2018-08-03 07:07:45.373 STDIO Thread-15 [INFO] jackson : 5
2018-08-03 07:07:45.374 STDIO Thread-15 [INFO] mike : 10
2018-08-03 07:07:45.374 STDIO Thread-15 [INFO] nathan : 11
2018-08-03 07:07:45.374 STDIO Thread-15 [INFO] golda : 17
2018-08-03 07:07:45.375 STDIO Thread-15 [INFO] bertels : 16
2018-08-03 07:07:46.375 STDIO Thread-15 [INFO] jackson : 5
2018-08-03 07:07:46.376 STDIO Thread-15 [INFO] mike : 10
2018-08-03 07:07:46.376 STDIO Thread-15 [INFO] nathan : 11
```  
可以看到统计数据时每秒统计一次。