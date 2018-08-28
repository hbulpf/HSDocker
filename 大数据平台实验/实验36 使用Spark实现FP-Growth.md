# 实验三十六 使用Spark实现FP-Growth

## 36.1 实验目的  
1.熟练使用Spark Shell接口；  
2.了解FP-Growth关联分析原理；  
3.了解FP-Growth算法执行过程；  
4.配置Spark处理HDFS数据；  
5.使用Spark机器学习包中FP-Growth算法处理HDFS中数据。  

## 36.2 实验要求  
使用Spark MLlib（机器学习库）中的FP-Growth算法，处理存储在HDFS上的数据集sample_fpgrowth.txt。  

## 36.3 实验原理  
### 36.3.1 FP-Growth算法简介  
FP的全称是Frequent Pattern，在算法中使用了一种称为频繁模式树（Frequent Pattern Tree）的数据结构。FP-tree是一种特殊的前缀树，由频繁项头表和项前缀树构成。所谓前缀树，是一种存储候选项集的数据结构，树的分支用项名标识，树的节点存储后缀项，路径表示项集。  

FP-tree的生成方法如图所示：  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex36/1.jpg)  

第二步根据支持度对频繁项进行排序是本算法的关键。第一点是，通过将支持度高的项排在前面，使得生成的FP-tree中，出现频繁的项更可能被共享，从而有效地节省算法运行所需要的空间。另一点是，通过这种排序，可以对FP-tree所包含的频繁模式进行互斥的空间拆分，得到相互独立的子集，而这些子集又组成了完整的信息。  

FP-tree子集分割方法:  
如上图，求p为前缀的投影数据库：根据头表的指针找到FP-tree的两个p节点，搜索出从这两个节点到树的根节点路径节点信息（包含支持度）。然后累加路径节点信息的支持度，删除非频繁项。对剩下的频繁项按照上一节的方法构建FP-tree。过程如下两图所示:  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex36/2.jpg)  

![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex36/3.jpg)  

### 36.3.2 FP-Growth算法流程  
基本思路是：不断地迭代FP-tree的构造和投影过程。  

对于每个频繁项，构造它的条件投影数据库和投影FP-tree。对每个新构建的FP-tree重复这个过程，直到构造的新FP-tree为空，或者只包含一条路径。当构造的FP-tree为空时，其前缀即为频繁模式；当只包含一条路径时，通过枚举所有可能组合并与此树的前缀连接即可得到频繁模式。  

## 36.4 实验步骤  
关联分析指的是从大规模数据集中寻找物品间的隐含关系，这些关系主要包括“频繁项集”和“关联规则”，挖掘出“频繁项集”后，可从中找出“关联规则”。当使用FP-Growth算法寻找频繁项时，其首先需要构建FP树，接着可通过查找元素项的条件基、构建条件FP树来发现频繁项集，最后再从该“频繁项集”中计算出“关联规则”下述步骤即讲述这一过程。  

### 36.4.1 准备实验数据  
这次要用到的数据依旧在/usr/local/spark/data/mllib目录下:  
```
root@hadoop-master:/usr/local/spark/data/mllib# ls
als                ridge-data                                  sample_lda_data.txt                sample_multiclass_classification_data.txt
gmm_data.txt       sample_binary_classification_data.txt       sample_lda_libsvm_data.txt         sample_svm_data.txt
kmeans_data.txt    sample_fpgrowth.txt                         sample_libsvm_data.txt             streaming_kmeans_data_test.txt
pagerank_data.txt  sample_isotonic_regression_libsvm_data.txt  sample_linear_regression_data.txt
pic_data.txt       sample_kmeans_data.txt                      sample_movielens_data.txt
```  
这次用的是**sample_fpgrowth.txt**,将其上传至HDFS:  
```
root@hadoop-master:/usr/local/spark/data/mllib# hadoop fs -put sample_fpgrowth.txt /
root@hadoop-master:/usr/local/spark/data/mllib# hadoop fs -ls /                     
Found 1 items
-rw-r--r--   2 root supergroup         68 2018-08-16 01:34 /sample_fpgrowth.txt
```  

### 36.4.2 训练模型  
进行spark-shell:  
```
root@hadoop-master:/usr/local/spark/data/mllib# spark-shell spark://hadoop-master:7077
```  

进入Spark Shell命令行执行环境后，依次输入下述代码:  
```
import org.apache.spark.mllib.fpm.FPGrowth
import org.apache.spark.rdd.RDD  

val data = sc.textFile("hdfs://hadoop-master:9000/sample_fpgrowth.txt")
val transactions: RDD[Array[String]] = data.map(s => s.trim.split(' '))  
val fpg = new FPGrowth().setMinSupport(0.2).setNumPartitions(10)  
val model = fpg.run(transactions)  

model.freqItemsets.collect().foreach { itemset =>
  println(itemset.items.mkString("[", ",", "]") + ", " + itemset.freq)
}  

val minConfidence = 0.8  
model.generateAssociationRules(minConfidence).collect().foreach { rule =>
  println(
    rule.antecedent.mkString("[", ",", "]")
      + " => " + rule.consequent .mkString("[", ",", "]")
      + ", " + rule.confidence)
}
```
待模型训练结束后，即可在测试数据集上，使用该模型，对测试样本进行分类。  

## 36.5 实验结果  
```
scala> model.generateAssociationRules(minConfidence).collect().foreach { rule =>
     | println(
     | rule.antecedent.mkString("[", ",", "]")
     | + " => " + rule.consequent .mkString("[", ",", "]")
     |  + ", " + rule.confidence)
     | }
[t,s,y] => [x], 1.0
[t,s,y] => [z], 1.0
[y,x,z] => [t], 1.0
[y] => [x], 1.0
[y] => [z], 1.0
[y] => [t], 1.0
[p] => [r], 1.0
[p] => [z], 1.0
[q,t,z] => [y], 1.0
[q,t,z] => [x], 1.0
[q,y] => [x], 1.0
[q,y] => [z], 1.0
[q,y] => [t], 1.0
[t,s,x] => [y], 1.0
[t,s,x] => [z], 1.0
[q,t,y,z] => [x], 1.0
[q,t,x,z] => [y], 1.0
[q,x] => [y], 1.0
[q,x] => [t], 1.0
[q,x] => [z], 1.0
[t,x,z] => [y], 1.0
[x,z] => [y], 1.0
[x,z] => [t], 1.0
[p,z] => [r], 1.0
[t] => [y], 1.0
[t] => [x], 1.0
[t] => [z], 1.0
[y,z] => [x], 1.0
[y,z] => [t], 1.0
[p,r] => [z], 1.0
[t,s] => [y], 1.0
[t,s] => [x], 1.0
[t,s] => [z], 1.0
[q,z] => [y], 1.0
[q,z] => [t], 1.0
[q,z] => [x], 1.0
[q,y,z] => [x], 1.0
[q,y,z] => [t], 1.0
[y,x] => [z], 1.0
[y,x] => [t], 1.0
[q,x,z] => [y], 1.0
[q,x,z] => [t], 1.0
[t,y,z] => [x], 1.0
[q,y,x] => [z], 1.0
[q,y,x] => [t], 1.0
[q,t,y,x] => [z], 1.0
[t,s,x,z] => [y], 1.0
[s,y,x] => [z], 1.0
[s,y,x] => [t], 1.0
[s,x,z] => [y], 1.0
[s,x,z] => [t], 1.0
[q,y,x,z] => [t], 1.0
[s,y] => [x], 1.0
[s,y] => [z], 1.0
[s,y] => [t], 1.0
[q,t,y] => [x], 1.0
[q,t,y] => [z], 1.0
[t,y] => [x], 1.0
[t,y] => [z], 1.0
[t,z] => [y], 1.0
[t,z] => [x], 1.0
[t,s,y,x] => [z], 1.0
[t,y,x] => [z], 1.0
[q,t] => [y], 1.0
[q,t] => [x], 1.0
[q,t] => [z], 1.0
[q] => [y], 1.0
[q] => [t], 1.0
[q] => [x], 1.0
[q] => [z], 1.0
[t,s,z] => [y], 1.0
[t,s,z] => [x], 1.0
[t,x] => [y], 1.0
[t,x] => [z], 1.0
[s,z] => [y], 1.0
[s,z] => [x], 1.0
[s,z] => [t], 1.0
[s,y,x,z] => [t], 1.0
[s] => [x], 1.0
[t,s,y,z] => [x], 1.0
[s,y,z] => [x], 1.0
[s,y,z] => [t], 1.0
[q,t,x] => [y], 1.0
[q,t,x] => [z], 1.0
[r,z] => [p], 1.0
```



