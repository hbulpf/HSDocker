# 实验十六  Spark实验：Spark综例

## 16.1 实验目的  
1．理解Spark编程思想；  
2．学会在Spark Shell中编写Scala程序；  
3．学会在Spark Shell中运行Scala程序。

## 16.2 实验要求
实验结束后，能够编写Scala代码解决一下问题，并能够自行分析执行过程。  
有三个RDD，要求统计rawRDDA中“aa”、“bb”两个单词出现的次数；要求对去重后的rawRDDA再去掉rawRDDB中的内容；最后将上述两个结果合并成同一个文件然后存入HDFS中。

## 16.3 实验原理
### 16.3.1 Scala
Scala是一门多范式的编程语言，一种类似java的编程语言，设计初衷是实现可伸缩的语言、并集成面向对象编程和函数式编程的各种特性。  

Scala有几项关键特性表明了它的面向对象的本质。例如，Scala中的每个值都是一个对象，包括基本数据类型（即布尔值、数字等）在内，连函数也是对象。另外，类可以被子类化，而且Scala还提供了基于mixin的组合（mixin-based composition）。  

与只支持单继承的语言相比，Scala具有更广泛意义上的类重用。Scala允许定义新类的时候重用“一个类中新增的成员定义（即相较于其父类的差异之处）”。Scala称之为mixin类组合。  

Scala还包含了若干函数式语言的关键概念，包括高阶函数（Higher-Order Function）、局部套用（Currying）、嵌套函数（Nested Function）、序列解读（Sequence Comprehensions）等等。  

Scala是静态类型的，这就允许它提供泛型类、内部类、甚至多态方法（Polymorphic Method）。另外值得一提的是，Scala被特意设计成能够与Java和.NET互操作。  

Scala可以与Java互操作。它用scalac这个编译器把源文件编译成Java的class文件。你可以从Scala中调用所有的Java类库，也同样可以从Java应用程序中调用Scala的代码。  

这让Scala得以使用为Java1.4、5.0或者6.0编写的巨量的Java类库和框架，Scala会经常性地针对这几个版本的Java进行测试。Scala可能也可以在更早版本的Java上运行，但没有经过正式的测试。Scala以BSD许可发布，并且数年前就已经被认为相当稳定了。  

Scala旨在提供一种编程语言，能够统一和一般化分别来自面向对象和函数式两种不同风格的关键概念。藉着这个目标与设计，Scala得以提供一些出众的特性，包括:  
（1）面向对象风格  
（2）函数式风格  
（3）更高层的并发模型  
Scala把Erlang风格的基于actor的并发带进了JVM。开发者可以利用Scala的actor模型在JVM上设计具伸缩性的并发应用程序，它会自动获得多核心处理器带来的优势，而不必依照复杂的Java线程模型来编写程序。  
（4）轻量级的函数语法: 高阶； 嵌套； 局部套用（Currying）； 匿名。  
（5）与XML集成:可在Scala程序中直接书写XML；可将XML转换成Scala类。  
（6）与Java无缝地互操作  

总而言之，Scala是一种函数式面向对象语言，它融汇了许多前所未有的特性，而同时又运行于JVM之上。  

### 16.3.2 Spark Shell
该命令用于以交互式方式编写并执行Spark App，且书写语法为Scala。  
下面的示例命令用于进入交互式执行器，进入执行器后，即可使用Scala语句以交互式方式编写并执行Spark-App。  
``[root@client spark]# bin/spark-shell --master spark://master:7077`  
在该示例中，**写明“--master spark://master:7077”的目的是使Spark Shell进入集群模式**，若不写明，则Spark Shell会默认进入单机模式。  
由于Spark使用Scala开发，而**Scala实际上在JVM中执行**，因此，我们搭建好Spark环境后，无需另外安装Scala组件。 

## 16.4 实验步骤

### 16.4.1 以集群模式启动spark-shell:  
```
root@master:~# spark-shell --master spark://master:7077
```
  
### 16.4.2 编写并执行scala代码:  
```
scala> val rawRDDA = sc.parallelize(List("!!bb##cc", "%%ccbb%%", "cc&&++aa"), 3)
rawRDDA: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[0] at parallelize at <console>:24

scala> val rawRDDB = sc.parallelize(List(("xx", 99), ("yy", 88), ("xx", 99), ("zz", 99)), 2)
rawRDDB: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[1] at parallelize at <console>:24

scala> val rawRDDC = sc.parallelize(List(("yy",88)), 1)
rawRDDC: org.apache.spark.rdd.RDD[(String, Int)] = ParallelCollectionRDD[2] at parallelize at <console>:24

scala> import org.apache.spark.HashPartitioner
import org.apache.spark.HashPartitioner

scala> var tempResultRDDA = rawRDDA.flatMap(line=>line.split("")).filter(allWord=>{allWord.contains("aa") || allWord.contains("bb")}).map(word=>(word, 1)).partitionBy(new HashPartitioner(2)).groupByKey().map((P:(String, Iterable[Int]))=>(P._1, P._2.sum))
tempResultRDDA: org.apache.spark.rdd.RDD[(String, Int)] = MapPartitionsRDD[8] at map at <console>:27

scala> var tempResultRDDBC = rawRDDB.distinct.subtract(rawRDDC)
tempResultRDDBC: org.apache.spark.rdd.RDD[(String, Int)] = MapPartitionsRDD[15] at subtract at <console>:29

scala> var resultRDDABC = tempResultRDDA.union(tempResultRDDBC)
resultRDDABC: org.apache.spark.rdd.RDD[(String, Int)] = UnionRDD[16] at union at <console>:35

scala> resultRDDABC.saveAsTextFile("hdfs://master:9000/resultRDDABC")
```

最长的那段代码:  
```
scala> var tempResultRDDA = rawRDDA.flatMap(line=>line.split("")
                    ).filter(allWord=>{allWord.contains("aa") || allWord.contains("bb")}
                    ).map(word=>(word, 1)
                    ).partitionBy(new HashPartitioner(2)
                    ).groupByKey(
                    ).map((P:(String, Iterable[Int]))=>(P._1, P._2.sum))
```


### 16.4.3 查看结果:  
```
root@master:~# hadoop fs -ls /
Found 3 items
-rw-r--r--   2 root supergroup         54 2018-07-20 02:12 /in.txt
drwxr-xr-x   - root supergroup          0 2018-07-20 03:06 /resultRDDABC
drwx-wx-wx   - root supergroup          0 2018-07-20 02:10 /tmp
root@master:~# hadoop fs -ls /resu*
Found 5 items
-rw-r--r--   2 root supergroup          0 2018-07-20 03:06 /resultRDDABC/_SUCCESS
-rw-r--r--   2 root supergroup          0 2018-07-20 03:06 /resultRDDABC/part-00000
-rw-r--r--   2 root supergroup          0 2018-07-20 03:06 /resultRDDABC/part-00001
-rw-r--r--   2 root supergroup         16 2018-07-20 03:06 /resultRDDABC/part-00002
-rw-r--r--   2 root supergroup          0 2018-07-20 03:06 /resultRDDABC/part-00003
root@master:~# hadoop fs -cat /resultRDDABC/p*
(xx,99)
(zz,99)
```



