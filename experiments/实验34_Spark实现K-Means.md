# 实验三十四 Spark实现K-Means 

## 34.1 实验目的  
1.熟练使用spark-shell接口；  
2.了解K-Means算法原理；  
3.理解K-Means执行过程；  
4.配置Spark处理HDFS数据；  
5.使用Spark机器学习包中K-Means工具包处理HDFS中数据。  

## 34.2 实验要求  
使用Spark MLlib（机器学习库）中的K-Means工具包，对存储在HDFS上的数据集进行聚类。  

## 34.3 实验原理  
请参考实验三十三实验原理。  

## 34.4 实验步骤  
原先的实验没有给数据集，不方便进行实验，从网上博客里找了个类似的实验。  

### 34.4.1 准备实验数据  
这个实验模拟的是游戏公司的玩家的月游戏时间及充值金额，通过两项数据对玩家进行分类。  

|ID|游戏时间|充值金额|
|:-:|:-:|:-:|
|1|60|55|
|2|30|22|
|3|15|11|
|4|288|300|
|5|223|200|
|6|0|0|
|7|14|5|
|8|320|280|
|9|65|55|
|10|13|0|
|11|10|18|
|12|115|108|
|13|3|0|
|14|52|40|
|15|62|76|
|16|73|80|
|17|45|30|
|18|1|0|
|19|180|166|
|20|90|86|


测试文件的内容只填游戏时间和充值金额，空格隔开:  
```
60 55
30 22
15 11
288 300
223 200
0 0
14 5
320 280
65 55
13 0
10 18
115 108
3 0
52 40
62 76
73 80
45 30
1 0
180 166
90 86
```

创建测试文件KMeansTest.data,并上传至HDFS: 
```
root@master:~# vim KMeansTest.data
root@master:~# hadoop fs -put KMeansTest.data /
```  

### 34.4.2 进行Spark-Shell，编写代码  
```  
root@master:~# spark-shell --master spark://master:7077
```  

代码部分(在shell交互里一行一行完成代码即可):  
```
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{SparkConf, SparkContext}  

val data =sc.textFile("hdfs://master:9000/KMeansTest.data")
val parsedData =data.map(s => Vectors.dense(s.split(' ').map(_.trim.toDouble))).cache()

//设置簇的个数为3
val numClusters =3
//迭代次数
val numIterations= 80
////运行10次,选出最优解
val runs=10

val clusters =KMeans.train(parsedData, numClusters, numIterations,runs)

//打印各簇中心点
for (center <-clusters.clusterCenters) { println(" "+ center) }  

//显示数据集每个玩家所在簇
println(parsedData.map(v=> v.toString() + " belong to cluster :" +clusters.predict(v)).collect().mkString("\n"))
```  

## 34.5 实验结果  
原实验里迭代次数只有20次，自己实验时发现分类效果特别差，逐渐加迭代次数，60，80才开始分类比较稳定,但还是会出现不理想的情况。  

较为理想的一次实验:  
```
scala> for (center <-clusters.clusterCenters) { println(" "+ center) } 
 [77.5,76.66666666666666]
 [252.75,236.5]
 [18.3,12.600000000000001]

scala> println(parsedData.map(v=> v.toString() + " belong to cluster :" +clusters.predict(v)).collect().mkString("\n"))
[60.0,55.0] belong to cluster :0
[30.0,22.0] belong to cluster :2
[15.0,11.0] belong to cluster :2
[288.0,300.0] belong to cluster :1
[223.0,200.0] belong to cluster :1
[0.0,0.0] belong to cluster :2
[14.0,5.0] belong to cluster :2
[320.0,280.0] belong to cluster :1
[65.0,55.0] belong to cluster :0
[13.0,0.0] belong to cluster :2
[10.0,18.0] belong to cluster :2
[115.0,108.0] belong to cluster :0
[3.0,0.0] belong to cluster :2
[52.0,40.0] belong to cluster :2
[62.0,76.0] belong to cluster :0
[73.0,80.0] belong to cluster :0
[45.0,30.0] belong to cluster :2
[1.0,0.0] belong to cluster :2
[180.0,166.0] belong to cluster :1
[90.0,86.0] belong to cluster :0

```  
可以看到玩家明显分成了三类。

cluster 0 对应普通玩家(有一些在线和充值金额)  
cluster 1 对应优质玩家(在线时间长，充值金额大)  
clustter 2 对应不活跃玩家(时间少，金额小)  

## 34.6 补充  
原博客完整代码:  
```
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{SparkConf, SparkContext}

object KMeansTest {
  def main(args: Array[String]) {
      val conf = new SparkConf()
      val sc = new SparkContext(conf)

    val data =sc.textFile(args(0))
    val parsedData =data.map(s => Vectors.dense(s.split(' ').map(_.trim.toDouble))).cache()

    //设置簇的个数为3
    val numClusters =3
    //迭代20次
    val numIterations= 20
    //运行10次,选出最优解
    val runs=10
    val clusters =KMeans.train(parsedData, numClusters, numIterations,runs)
    // Evaluateclustering by computing Within Set Sum of Squared Errors
    val WSSSE = clusters.computeCost(parsedData)
    println("WithinSet Sum of Squared Errors = " + WSSSE)

    val a21 =clusters.predict(Vectors.dense(57.0,30.0))
    val a22 =clusters.predict(Vectors.dense(0.0,0.0))

    //打印出中心点
    println("Clustercenters:");
    for (center <-clusters.clusterCenters) {
      println(" "+ center)
    }

    //打印出测试数据属于哪个簇
    println(parsedData.map(v=> v.toString() + " belong to cluster :" +clusters.predict(v)).collect().mkString("\n"))
    println("预测第21个用户的归类为-->"+a21)
    println("预测第22个用户的归类为-->"+a22)
  }
}
```  

**原博客其实本应该是跟实验十九类似，在开发工具中创建scala项目，完成代码后打包成jar包实行，其实最开始也是这样做的，但是在spark-submit去提交jar包执行时会报错并中断，原因不明。**  

# 实验三十四补充  
做到实验三十五才发现原实验测试的数据集都是spark自带的，重新完成原实验三十四的内容:  

## 1.准备数据集  
```
scala> root@master:/usr/local/spark/data/mllib# ls
als              pagerank_data.txt                      sample_isotonic_regression_libsvm_data.txt  sample_linear_regression_data.txt
derby.log        pic_data.txt                           sample_kmeans_data.txt                      sample_movielens_data.txt
gmm_data.txt     ridge-data                             sample_lda_data.txt                         sample_multiclass_classification_data.txt
kmeans_data.txt  sample_binary_classification_data.txt  sample_lda_libsvm_data.txt                  sample_svm_data.txt
metastore_db     sample_fpgrowth.txt                    sample_libsvm_data.txt   
```  
这次用的是**kmeans_data.txt**,上传至HDFS:  
```
root@master:/usr/local/spark/data/mllib# hadoop fs -put kmeans_data.txt /
root@master:/usr/local/spark/data/mllib# hadoop fs -ls /                 
Found 1 items
-rw-r--r--   2 root supergroup         72 2018-08-16 01:49 /kmeans_data.txt
```  

## 2.训练模型  
进入spark-shell:  
```
root@master:/usr/local/spark/data/mllib# spark-shell spark://master:7077
```  

进入spark-shell命令行执行环境后，依次输入下述代码:  
```
import breeze.linalg.{Vector, DenseVector, squaredDistance}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.SparkContext._

def parseVector(line: String): Vector[Double] = {
DenseVector(line.split(' ').map(_.toDouble))
}

def closestPoint(p: Vector[Double], centers: Array[Vector[Double]]): Int = {
var bestIndex = 0
var closest = Double.PositiveInfinity
for (i <- 0 until centers.length) {
val tempDist = squaredDistance(p, centers(i))
if (tempDist < closest) {
closest = tempDist
bestIndex = i
}
}
bestIndex
}

val lines = sc.textFile("/kmeans_data.txt")
val data = lines.map(parseVector _).cache()
val K = "2".toInt
val convergeDist = "0.1".toDouble
val kPoints = data.takeSample(withReplacement = false, K, 42).toArray
var tempDist = 1.0

while(tempDist > convergeDist) {
val closest = data.map (p => (closestPoint(p, kPoints), (p, 1)))
val pointStats = closest.reduceByKey{case ((p1, c1), (p2, c2)) => (p1 + p2, c1 + c2)}
val newPoints = pointStats.map {pair =>
(pair._1, pair._2._1 * (1.0 / pair._2._2))}.collectAsMap()
tempDist = 0.0
for (i <- 0 until K) {
tempDist += squaredDistance(kPoints(i), newPoints(i))
}
for (newP <- newPoints) {
kPoints(newP._1) = newP._2
}
println("Finished iteration (delta = " + tempDist + ")")
}

println("Final centers:")
kPoints.foreach(println)
```

部分过程截图:  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex34/Screenshot%20from%202018-08-16%2009-59-14.png)  

![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex34/Screenshot%20from%202018-08-16%2009-58-58.png)  

## 3 实验结果  
代码最后一行便是在控制台上打印中心点:  
```  
scala> kPoints.foreach(println)
DenseVector(9.099999999999998, 9.099999999999998, 9.099999999999998)
DenseVector(0.1, 0.1, 0.1)
```  
