# 实验十五  Spark实验：RDD综合实验

## 15.1 实验目的
1．通过Spark-shell的操作理解RDD操作；  
2．能通过RDD操作的执行理解RDD的原理；  
3．对Scala能有一定的认识。

## 15.2 实验要求
在实验结束时能完成max，first，distinct，foreach等api的操作。

## 15.3 实验原理
RDD(Resilient Distributed Datasets，弹性分布式数据集)是一个**分区的只读记录的集合**。RDD只能通过在稳定的存储器或其他RDD的数据上的确定性操作来创建。我们把这些操作称作变换以区别其他类型的操作。例如 map、filter和join。  

RDD在任何时候都不需要被“物化”（进行实际的变换并最终写入稳定的存储器上）。实际上，一个RDD有足够的信息描述着其如何从其他稳定的存储器上的数据生成。它有一个强大的特性：从本质上说，若RDD失效且不能重建，程序将不能引用该RDD。而用户可以控制RDD的其他两个方面：持久化和分区。用户可以选择重用哪个RDD，并为其制定存储策略(比如：内存存储)。也可以让RDD中的数据根据记录的key分布到集群的多个机器。这对位置优化来说是有用的，比如可用来保证两个要join的数据集都使用了相同的哈希分区方式。  

编程人员可通过Spark编程接口对稳定存储上的数据进行变换操作(如map和filter)，得到一个或多个RDD。然后可以调用这些RDD的actions(动作)类的操作。这类操作的目是返回一个值或是将数据导入到存储系统中。动作类的操作如count(返回数据集的元素数)，collect(返回元素本身的集合)和save(输出数据集到存储系统)。Spark直到RDD第一次调用一个动作时才真正计算RDD。  

还可以调用RDD的persist(持久化)方法来表明该RDD在后续操作中还会用到。默认情况下，Spark会将调用过persist的RDD存在内存中。但若内存不足，也可以将其写入到硬盘上。通过指定persist函数中的参数，用户也可以请求其他持久化策略(如Tachyon)并通过标记来进行persist，比如仅存储到硬盘上或是在各机器之间复制一份。最后，用户可以在每个RDD上设定一个持久化的优先级来指定内存中的哪些数据应该被优先写入到磁盘。 缓存有个缓存管理器，Spark里被称作blockmanager。注意，这里还有一个误区是，很多人认为调用了cache或者persist的那一刻就是在缓存了，这是完全不对的，真正的缓存执行指挥在action被触发。  

总结：RDD是分布式只读且已分区集合对象。这些集合是弹性的，如果数据集一部分丢失，则可以对它们进行重建。具有自动容错、位置感知调度和可伸缩性，而容错性是最难实现的，大多数分布式数据集的容错性有两种方式：数据检查点和记录数据的更新。对于大规模数据分析系统，数据检查点操作成本高，主要原因是大规模数据在服务器之间的传输带来的各方面的问题，相比记录数据的更新，RDD也只支持粗粒度的转换，也就是记录如何从其他RDD转换而来(即lineage)，以便恢复丢失的分区。  

简而言之，特性如下：  
1．数据结构不可变 ；  
2．支持跨集群的分布式数据操作 ；  
3．可对数据记录按key进行分区 ；  
4．提供了粗粒度的转换操作 ；  
5．数据存储在内存中，保证了低延迟性。

## 15.4 实验步骤  

启动spark-shell,需要注意实验需要以本地模式启动,直接输入命令spark-shell，如果以集群模式启动，有可能无法查看输出结果。(集群模式即后面带有--master spark://hadoop-master:7077)

### 15.4.1 distinct 去除RDD内的重复数据
```
scala> var a = sc.parallelize(List("Gnu","Cat","Rat","Dog","Gnu","Rat"),2);
a: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[0] at parallelize at <console>:24

scala> a.distinct.collect
res0: Array[String] = Array(Dog, Cat, Gnu, Rat)
```

### 15.4.2 foreach 遍历RDD内的数据
```
scala> var b = sc.parallelize(List("cat","dog","tiger","lion","gnu","crocodile","ant","whale","dolphin","spider"),3)
b: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[4] at parallelize at <console>:24

scala> b.foreach(x=>println(x+"s are yummy"))
ants are yummy
cats are yummy
dogs are yummy
tigers are yummy
lions are yummy
gnus are yummy
crocodiles are yummy
whales are yummy
dolphins are yummy
spiders are yummy
```

### 15.4.3 first 取的RDD中的第一个数据
```
scala> var c=sc.parallelize(List("dog","Cat","Rat","Dog"),2)
c: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[5] at parallelize at <console>:24

scala> c.first
res3: String = dog
```

### 15.4.4 max 取得RDD中的最大的数据
```
scala> var d=sc.parallelize(10 to 30)
d: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[6] at parallelize at <console>:24

scala> d.max
res4: Int = 30

scala> var e = sc.parallelize(List((10,"dog"),(20,"cat"),(30,"tiger"),(18,"lion")))
e: org.apache.spark.rdd.RDD[(Int, String)] = ParallelCollectionRDD[7] at parallelize at <console>:24

scala> e.max
res5: (Int, String) = (30,tiger)
```

### 15.4.5 intersection 返回两个RDD重叠的数据
```
scala> var f = sc.parallelize(1 to 20)
f: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[8] at parallelize at <console>:24

scala> var g = sc.parallelize(10 to 30)
g: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[9] at parallelize at <console>:24

scala> var h = f.intersection(g)
h: org.apache.spark.rdd.RDD[Int] = MapPartitionsRDD[15] at intersection at <console>:28

scala> h.collect
res6: Array[Int] = Array(16, 17, 18, 10, 19, 11, 20, 12, 13, 14, 15)
```





