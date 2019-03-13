# 实验十九  Spark实验：GraphX
## 19.1 实验目的  
1．了解Spark的图计算框架GraphX的基本知识；  
2．能利用GraphX进行建图；  
3．能利用GraphX进行基本的图操作；  
4．理解GraphX图操作的算法。

## 19.2 实验要求
要求实验结束时，每位学生能完成正确运行Spark GraphX的示例程序，正确上传到集群中运行得到正确的实验结果。  实验结束时能对实验代码进行一定的理解。  

## 19.3 实验原理
Spark GraphX是一个**分布式图处理框架**，Spark GraphX基于Spark平台提供对图计算和图挖掘简洁易用的而丰富多彩的接口，极大的方便了大家对分布式图处理的需求。  

社交网络中人与人之间有很多关系链，例如Twitter、Facebook、微博、微信，这些都是大数据产生的地方，都需要图计算，现在的图处理基本都是分布式的图处理，而并非单机处理，Spark GraphX由于底层是基于Spark来处理的，所以天然就是一个分布式的图处理系统。  

图的分布式或者并行处理其实是把这张图拆分成很多的子图，然后我们分别对这些子图进行计算，计算的时候可以分别迭代进行分阶段的计算，即对图进行并行计算。  

适用范围：图计算。 

## 19.4 实验步骤  

### 19.4.1 在intellij IDEA 中安装Scala的插件
点击File -> Settings -> Plugins -> 输入”Scala” 搜索 -> 点击搜索条目为Scala的项目-> 点击右侧绿色按钮Install -> 安装完成之后重启IDEA 

### 19.4.2 新建Scala Module  
IDEA中创建Empty project,model选择Scala输入module name “sparkgraphx”。点击新建的sparkgraphx的module然后右键点击”Add Framework Support”选择maven支持。  

### 19.4.3 添加maven依赖
在pom.xml文件中添加以下依赖:  
```xml
    <dependencies>
        <!-- https://mvnrepository.com/artifact/org.apache.spark/spark-graphx -->
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-graphx_2.11</artifactId>
            <version>2.2.3</version>
        </dependency>
    </dependencies>
``` 
等待依赖导入  

### 19.4.4 新建Scala程序  
打开项目目录然后右键新建package命名为test，然后新建Scala class将Kindt由class改为object。输入名字为GraphXExample。  
(如果右键点击New没发现有Scala class,打开File-> Project Structure -> Global Libraries -> “+” -> Scala SDK -> 选择一个版本加入即可)

输入代码:  
```scala
package test
 
import org.apache.log4j.{Level, Logger}
import org.apache.spark.graphx._
import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}
 
object GraphXExample {
  def main(args: Array[String]) {
    Logger.getLogger("org.apache.spark").setLevel(Level.ERROR)
    Logger.getLogger("org.eclipse.jetty.server").setLevel(Level.OFF)

    val conf = new SparkConf().setAppName("SimpleGraphX").setMaster("local")
    val sc = new SparkContext(conf)

    val vertexArray = Array(
        (1L, ("Alice", 28)),
        (2L, ("Bob", 27)),
        (3L, ("Charlie", 65)),
        (4L, ("David", 42)),
        (5L, ("Ed", 55)),
        (6L, ("Fran", 50))
    )

    val edgeArray = Array(
        Edge(2L, 1L, 7),
        Edge(2L, 4L, 2),
        Edge(3L, 2L, 4),
        Edge(3L, 6L, 3),
        Edge(4L, 1L, 1),
        Edge(5L, 2L, 2),
        Edge(5L, 3L, 8),
        Edge(5L, 6L, 3)
    )

    val vertexRDD: RDD[(Long, (String, Int))] = sc.parallelize(vertexArray)
    val edgeRDD: RDD[Edge[Int]] = sc.parallelize(edgeArray)

    val graph: Graph[(String, Int), Int] = Graph(vertexRDD, edgeRDD)

    println("属性演示")
    println("**********************************************************")
    println("找出图中年龄大于30的顶点：")
    graph.vertices.filter { case (id, (name, age)) => age > 30}.collect.foreach {
        case (id, (name, age)) => println(s"$name is $age")
    }

    println("找出图中属性大于5的边：")
    graph.edges.filter(e => e.attr > 5).collect.foreach(e => println(s"${e.srcId} to ${e.dstId} att ${e.attr}"))
    println

    println("列出边属性>5的tripltes：")
    for (triplet <- graph.triplets.filter(t => t.attr > 5).collect) {
       println(s"${triplet.srcAttr._1} likes ${triplet.dstAttr._1}")
    }
    println

    println("找出图中最大的出度、入度、度数：")
    def max(a: (VertexId, Int), b: (VertexId, Int)): (VertexId, Int) = {
       if (a._2 > b._2) a else b
    }
    println("max of outDegrees:" + graph.outDegrees.reduce(max) + " max of inDegrees:" + graph.inDegrees.reduce(max) + " max of Degrees:" + graph.degrees.reduce(max))
    println

    println("**********************************************************")
    println("转换操作")
    println("**********************************************************")
    println("顶点的转换操作，顶点age + 10：")
    graph.mapVertices{ case (id, (name, age)) => (id, (name, age+10))}.vertices.collect.foreach(v => println(s"${v._2._1} is ${v._2._2}"))
    println
    println("边的转换操作，边的属性*2：")
    graph.mapEdges(e=>e.attr*2).edges.collect.foreach(e => println(s"${e.srcId} to ${e.dstId} att ${e.attr}"))
    println

    println("**********************************************************")
    println("结构操作")
    println("**********************************************************")
    println("顶点年纪>30的子图：")
    val subGraph = graph.subgraph(vpred = (id, vd) => vd._2 >= 30)
    println("子图所有顶点：")
    subGraph.vertices.collect.foreach(v => println(s"${v._2._1} is ${v._2._2}"))
    println
    println("子图所有边：")
    subGraph.edges.collect.foreach(e => println(s"${e.srcId} to ${e.dstId} att ${e.attr}"))
    println


    println("**********************************************************")
    println("连接操作")
    println("**********************************************************")
    val inDegrees: VertexRDD[Int] = graph.inDegrees
    case class User(name: String, age: Int, inDeg: Int, outDeg: Int)

    val initialUserGraph: Graph[User, Int] = graph.mapVertices { case (id, (name, age)) => User(name, age, 0, 0)}

    val userGraph = initialUserGraph.outerJoinVertices(initialUserGraph.inDegrees) {
       case (id, u, inDegOpt) => User(u.name, u.age, inDegOpt.getOrElse(0), u.outDeg)
    }.outerJoinVertices(initialUserGraph.outDegrees) {
       case (id, u, outDegOpt) => User(u.name, u.age, u.inDeg,outDegOpt.getOrElse(0))
    }

    println("连接图的属性：")
    userGraph.vertices.collect.foreach(v => println(s"${v._2.name} inDeg: ${v._2.inDeg}  outDeg: ${v._2.outDeg}"))
    println

    println("出度和入度相同的人员：")
    userGraph.vertices.filter {
       case (id, u) => u.inDeg == u.outDeg
    }.collect.foreach {
       case (id, property) => println(property.name)
    }
    println


    println("**********************************************************")
    println("聚合操作")
    println("**********************************************************")
    println("找出5到各顶点的最短：")
    val sourceId: VertexId = 5L
    val initialGraph = graph.mapVertices((id, _) => if (id == sourceId) 0.0 else Double.PositiveInfinity)
    val sssp = initialGraph.pregel(Double.PositiveInfinity)(
      (id, dist, newDist) => math.min(dist, newDist),
      triplet => {
        if (triplet.srcAttr + triplet.attr < triplet.dstAttr) {
            Iterator((triplet.dstId, triplet.srcAttr + triplet.attr))
        } else {
            Iterator.empty
        }
    },
        (a,b) => math.min(a,b)
    )
    println(sssp.vertices.collect.mkString("\n"))

    sc.stop()
  }
}
```


### 19.4.5 提交任务
按照上个实验里相同的方式打包成jar包，传到master节点  
```
root@master:~# spark-submit --class test.GraphXExample sparkgraphx.jar 
java.lang.ClassNotFoundException: test.GraphXExample
	at java.net.URLClassLoader.findClass(URLClassLoader.java:381)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:424)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:357)
	at java.lang.Class.forName0(Native Method)
	at java.lang.Class.forName(Class.java:348)
	at org.apache.spark.util.Utils$.classForName(Utils.scala:229)
	at org.apache.spark.deploy.SparkSubmit$.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:695)
	at org.apache.spark.deploy.SparkSubmit$.doRunMain$1(SparkSubmit.scala:187)
	at org.apache.spark.deploy.SparkSubmit$.submit(SparkSubmit.scala:212)
	at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:126)
	at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
```
一直报错说ClassNotFoundException，尚未解决。








