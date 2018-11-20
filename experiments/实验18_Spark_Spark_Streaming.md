# 实验十八 Spark实验：Spark Streaming

## 18.1 实验目的  
1．了解Spark Streaming版本的WordCount和MapReduce版本的WordCount的区别；  
2．理解Spark Streaming的工作流程；  
3．理解Spark Streaming的工作原理。

## 18.2 实验要求
要求实验结束时，每位学生能正确运行成功本实验中所写的jar包程序，能正确的计算出单词数目。

## 18.3 实验原理
### 18.3.1 Spark Streaming 架构
计算流程：Spark Streaming是**将流式计算分解成一系列短小的批处理作业**。这里的批处理引擎是Spark，也就是把Spark Streaming的输入数据按照**batch size**（如1秒）分成一段一段的数据（Discretized Stream），**每一段数据都转换成Spark中的RDD（Resilient Distributed Dataset）**，然后将Spark Streaming中对DStream的Transformation操作变为针对Spark中对RDD的Transformation操作，将RDD经过操作变成中间结果保存在内存中。整个流式计算根据业务的需求可以对中间的结果进行叠加，或者存储到外部设备。如图所示：  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex18/1.jpg)  

容错性：对于流式计算来说，容错性至关重要。首先我们要明确一下Spark中RDD的容错机制。每一个RDD都是一个不可变的分布式可重算的数据集，其记录着确定性的操作继承关系（lineage），所以只要输入数据是可容错的，那么任意一个RDD的分区（Partition）出错或不可用，都是可以利用原始输入数据通过转换操作而重新算出的。  

对于Spark Streaming来说，其RDD的传承关系如下图所示，图中的每一个**椭圆形表示一个RDD**，椭圆形中的每个**圆形代表一个RDD中的一个Partition**，图中的每**一列的多个RDD表示一个DStream**（图中有三个DStream），而**每一行最后一个RDD则表示每一个Batch Size所产生的中间结果RDD**。我们可以看到图中的每一个RDD都是通过lineage相连接的，由于Spark Streaming输入数据可以来自于磁盘，例如HDFS（多份拷贝）或是来自于网络的数据流（Spark Streaming会将网络输入数据的每一个数据流拷贝两份到其他的机器）都能保证容错性。所以RDD中任意的Partition出错，都可以并行地在其他机器上将缺失的Partition计算出来。这个容错恢复方式比连续计算模型（如Storm）的效率更高。 如图所示：  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex18/2.jpg)  

实时性：对于实时性的讨论，会牵涉到流式处理框架的应用场景。Spark Streaming将流式计算分解成多个Spark Job，对于每一段数据的处理都会经过Spark DAG图分解，以及Spark的任务集的调度过程。对于目前版本的Spark Streaming而言，其**最小的Batch Size的选取在0.5~2秒钟之间**（Storm目前最小的延迟是100ms左右），所以Spark Streaming能够满足除对实时性要求非常高（如高频实时交易）之外的所有流式准实时计算场景。  

扩展性与吞吐量：Spark目前在EC2上已能够线性扩展到100个节点（每个节点4Core），可以以数秒的延迟处理6GB/s的数据量（60M records/s），其吞吐量也比流行的Storm高2～5倍，图4是Berkeley利用WordCount和Grep两个用例所做的测试，在Grep这个测试中，Spark Streaming中的每个节点的吞吐量是670k records/s，而Storm是115k records/s。如图所示：  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex18/3.jpg)  

### 18.3.2 Spark Streaming 编程模型
Spark Streaming的编程和Spark的编程如出一辙，对于编程的理解也非常类似。**对于Spark来说，编程就是对于RDD的操作**；而**对于Spark Streaming来说，就是对DStream的操作**。下面将通过一个大家熟悉的WordCount的例子来说明Spark Streaming中的输入操作、转换操作和输出操作。  

Spark Streaming初始化：在开始进行DStream操作之前，需要对Spark Streaming进行**初始化生成StreamingContext**。参数中比较重要的是第一个和第三个，**第一个参数是指定Spark Streaming运行的集群地址**，而**第三个参数是指定Spark Streaming运行时的batch窗口大小**。在这个例子中就是将1秒钟的输入数据进行一次Spark Job处理。  
``val ssc = new StreamingContext("Spark://…", "WordCount", Seconds(1), [Homes], [Jars])``  

Spark Streaming的输入操作：目前Spark Streaming已支持了丰富的输入接口，大致分为两类：**一类是磁盘输入**，如以batch size作为时间间隔监控HDFS文件系统的某个目录，将目录中内容的变化作为Spark Streaming的输入；**另一类就是网络流的方式**，目前支持Kafka、Flume、Twitter和TCP socket。在WordCount例子中，假定通过网络socket作为输入流，监听某个特定的端口，最后得出输入DStream（lines）。  
``val lines = ssc.socketTextStream("localhost",8888)``  

Spark Streaming的转换操作：与Spark RDD的操作极为类似，Spark Streaming也就是**通过转换操作将一个或多个DStream转换成新的DStream**。常用的操作包括map、filter、flatmap和join，以及需要进行shuffle操作的groupByKey/reduceByKey等。在WordCount例子中，我们首先需要将DStream(lines)切分成单词，然后将相同单词的数量进行叠加, 最终得到的wordCounts就是每一个batch size的（单词，数量）中间结果。  
```
val words = lines.flatMap(_.split(" "))
val wordCounts = words.map(x => (x, 1)).reduceByKey(_ + _)
```  

另外，Spark Streaming有特定的窗口操作，**窗口操作涉及两个参数：一个是滑动窗口的宽度（Window Duration）；另一个是窗口滑动的频率（Slide Duration），这两个参数必须是batch size的倍数**。例如以过去5秒钟为一个输入窗口，每1秒统计一下WordCount，那么我们会将过去5秒钟的每一秒钟的WordCount都进行统计，然后进行叠加，得出这个窗口中的单词统计。  
``val wordCounts = words.map(x => (x, 1)).reduceByKeyAndWindow(_ + _, Seconds(5s)，seconds(1))``  

但上面这种方式还不够高效。如果我们以增量的方式来计算就更加高效，例如，计算t+4秒这个时刻过去5秒窗口的WordCount，那么我们可以将t+3时刻过去5秒的统计量加上[t+3，t+4]的统计量，在减去[t-2，t-1]的统计量，这种方法可以复用中间三秒的统计量，提高统计的效率。如图18-4所示：  
``val wordCounts = words.map(x => (x, 1)).reduceByKeyAndWindow(_ + _, _ - _, Seconds(5s)，seconds(1))``  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex18/4.jpg)  

Spark Streaming的输出操作：对于输出操作，Spark提供了将数据打印到屏幕及输入到文件中。在WordCount中我们将DStream wordCounts输入到HDFS文件中。  
``wordCounts = saveAsHadoopFiles("WordCount")``  

Spark Streaming启动：经过上述的操作，Spark Streaming还没有进行工作，我们还需要调用Start操作，Spark Streaming才开始监听相应的端口，然后收取数据，并进行统计。  
``ssc.start()``  

### 18.3.3 Spark Streaming典型案例
在互联网应用中，网站流量统计作为一种常用的应用模式，需要在不同粒度上对不同数据进行统计，既有实时性的需求，又需要涉及到聚合、去重、连接等较为复杂的统计需求。传统上，若是使用Hadoop MapReduce框架，虽然可以容易地实现较为复杂的统计需求，但实时性却无法得到保证；反之若是采用Storm这样的流式框架，实时性虽可以得到保证，但需求的实现复杂度也大大提高了。Spark Streaming在两者之间找到了一个平衡点，能够以准实时的方式容易地实现较为复杂的统计需求。 下面介绍一下使用Kafka和Spark Streaming搭建实时流量统计框架。  

数据暂存：Kafka作为分布式消息队列，既有非常优秀的吞吐量，又有较高的可靠性和扩展性，在这里采用Kafka作为日志传递中间件来接收日志，抓取客户端发送的流量日志，同时接受Spark Streaming的请求，将流量日志按序发送给Spark Streaming集群。  

数据处理：将Spark Streaming集群与Kafka集群对接，Spark Streaming从Kafka集群中获取流量日志并进行处理。Spark Streaming会实时地从Kafka集群中获取数据并将其存储在内部的可用内存空间中。当每一个batch窗口到来时，便对这些数据进行处理。  

结果存储：为了便于前端展示和页面请求，处理得到的结果将写入到数据库中。  

相比于传统的处理框架，Kafka+Spark Streaming的架构有以下几个优点。Spark框架的高效和低延迟保证了Spark Streaming操作的准实时性。利用Spark框架提供的丰富API和高灵活性，可以精简地写出较为复杂的算法。编程模型的高度一致使得上手Spark Streaming相当容易，同时也可以保证业务逻辑在实时处理和批处理上的复用。  
Spark Streaming提供了一套高效、可容错的准实时大规模流式处理框架，它能和批处理及即时查询放在同一个软件栈中。如果你学会了Spark编程，那么也就学会了Spark Streaming编程，如果理解了Spark的调度和存储，Spark Streaming也类似。按照目前的发展趋势，Spark Streaming一定将会得到更大范围的使用。  

## 18.4 实验步骤  

### 18.4.1 启动hadoop和spark
正常启动hadoop和spark

### 18.4.2 编写代码
由于是Maven项目，不适合在容器里继续操作，代码在主机端通过idea进行编写。  

打开IntelliJ IDEA，点击File -> New -> Module-> Maven->Next –> 输入GroupId和AriifactId -> Next -> 输入Module name  新建一个maven的Module。打开项目录，点击目录下的pom.xml文件，在<project>标签中输入maven的依赖。  

```xml
<build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>1.6</source>
                    <target>1.6</target>
                </configuration>
            </plugin>
        </plugins>
</build>

<dependencies>
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-streaming_2.10</artifactId>
            <version>1.6.0</version>
        </dependency>
 </dependencies>
```

等待下载所需依赖。  

下载完成后，在src/main/java的目录下，点击java目录新建一个package命名为**spark.streaming.test**，然后在包下新建一个**SparkStreaming**的java class。  

代码如下:  

```java
package spark.streaming.test;
 
import scala.Tuple2;
import com.google.common.collect.Lists;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function2;
import org.apache.spark.api.java.function.PairFunction;
import org.apache.spark.api.java.StorageLevels;
import org.apache.spark.streaming.Durations;
import org.apache.spark.streaming.api.java.JavaDStream;
import org.apache.spark.streaming.api.java.JavaPairDStream;
import org.apache.spark.streaming.api.java.JavaReceiverInputDStream;
import org.apache.spark.streaming.api.java.JavaStreamingContext;
 
import java.util.Iterator;
import java.util.regex.Pattern;
 
public class SparkStreaming {
    private static final Pattern SPACE = Pattern.compile(" ");

    public static void main(String[] args) throws InterruptedException {
        if (args.length < 2) {
            System.err.println("Usage: JavaNetworkWordCount <hostname> <port>");
            System.exit(1);
        }


        SparkConf sparkConf = new SparkConf().setAppName("JavaNetworkWordCount");
        JavaStreamingContext ssc = new JavaStreamingContext(sparkConf, Durations.seconds(1));
        JavaReceiverInputDStream<String> lines = ssc.socketTextStream(
                args[0], Integer.parseInt(args[1]), StorageLevels.MEMORY_AND_DISK_SER);
        JavaDStream<String> words = lines.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public Iterable<String> call(String x){
                return Lists.newArrayList(SPACE.split(x));
            }
        });
        JavaPairDStream<String, Integer> wordCounts = words.mapToPair(
                new PairFunction<String, String, Integer>() {
                    @Override
                    public Tuple2<String, Integer> call(String s) {
                        return new Tuple2<String, Integer>(s, 1);
                    }
                }).reduceByKey(new Function2<Integer, Integer, Integer>() {
            @Override
            public Integer call(Integer i1, Integer i2) {
                return i1 + i2;
            }
        });
 
        wordCounts.print();
        ssc.start();
        ssc.awaitTermination();
    }
}
```

点击File -> Project Structure -> Aritifacts –>点击加号 -> JAR -> from modules with dependences -> 选择刚才新建的module –> 选择Main Class -> Ok -> 选择Output directory –>点击Ok。**去掉除 ’guava-14.0.1.jar’ 和 ‘guice-3.0.jar’以外所有的JAR包**，点击Ok。    

![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex18/Screenshot%20from%202018-07-24%2015-54-24.png)    


![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex18/Screenshot%20from%202018-07-24%2015-54-48.png)  

点击Build -> Build Aritifacts 。  将生成的jar包传至master节点。  


### 18.4.3 提交spark任务，测试结果
```spark-submit --class spark.streaming.test.SparkStreaming sparkstreaming.jar localhost 9999```   
任务提交完后刷新频率很快(每s一次)  
```
-------------------------------------------
Time: 1532565890000 ms
-------------------------------------------
```  
重点在于这样的一串，如有结果，都是显示在这个时间的下方。  

实验十八里说测试结果是，新建一个SSH连接到master节点，通过nc -lk 9999命令设置路由器，并输入测试数据,像是这样 
```
[root@master ~]# nc -lk 9999
The weather is nice today The weather is nice today The weather is nice today
```
然后结果会显示在不断刷新的时间下，但实际操作过程中一旦按回车输入测试数据，sparkStreaming任务就会自动停止，尚未解决。

