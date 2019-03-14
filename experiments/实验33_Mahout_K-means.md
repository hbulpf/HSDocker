# 实验三十三  Mahout实验：K-means  

## 33.1 实验目的  
1.了解Mahout是什么；  
2.了解Mahout能够做什么；  
3.学会启动Mahout；  
4.能够通过提交MapReduce程序进行K-means实验。  

## 33.2 实验要求  
要求实验结束时，每位学生能够在Hadoop集群上利用Mahout提交K-means程序，并得出实验正确结果。  

## 33.3 实验原理  
### 33.3.1 Mahout简介  
Apache Mahout 是 Apache Software Foundation (ASF)开发的一个全新的开源项目，其主要目标是创建一些可伸缩的机器学习算法，供开发人员在Apache在许可下免费使用。该项目已经发展到了它的第二个年头，目前只有一个公共发行版。Mahout包含许多实现，包括集群、分类、CP和进化程序。此外，通过使用Apache Hadoop库，Mahout可以有效地扩展到云中。  

### 33.3.2 Mahout发展  
Mahout项目是由Apache Lucene（开源搜索）社区中对机器学习感兴趣的一些成员发起的，他们希望建立一个可靠、文档翔实、可伸缩的项目，在其中实现一些常见的用于集群和分类的机器学习算法。该社区最初基于Ng et al.的文章 “Map-Reduce for Machine Learning on Multicore”，但此后在发展中又并入了更多广泛的机器学习方法。Mahout的目标还包括：  
(1)建立一个用户和贡献者社区，使代码不必依赖于特定贡献者的参与或任何特定公司和大学的资金。  
(2)专注于实际用例，这与高新技术研究及未经验证的技巧相反。  
(3)提供高质量文章和示例。  

### 33.3.3 Mahout特性  
虽然在开源领域中相对较为年轻，但Mahout已经提供了大量功能，特别是在集群和CF方面。Mahout的主要特性包括：  
(1)Taste CF。Taste是Sean Owen在SourceForge上发起的一个针对CF的开源项目，并在2008年被赠予Mahout。  
(2)一些支持Map-Reduce的集群实现包括K-means、模糊K-means、Canopy、Dirichlet和Mean-Shift。  
(3)Distributed Naive Bayes和Complementary Naive Bayes分类实现。  
(4)针对进化编程的分布式适用性功能。  
(5)Matrix和矢量库。  
本实验主要介绍K-means。  

### 33.3.4 K-means算法概要  
K-means算法是一种计算数据聚集的算法，如图所示：  
![图]()  

从上图中，我们可以看到，A, B, C, D, E 是五个在图中点。而灰色的点是我们的种子点，也就是我们用来找点群的点。有两个种子点，所以K=2。  

然后，K-means的算法如下：  
(1)随机在图中取K（这里K=2）个种子点。  
(2)然后对图中的所有点求到这K个种子点的距离，假如点Pi离种子点Si最近，那么Pi属于Si点群。（上图中，我们可以看到A,B属于上面的种子点，C,D,E属于下面中部的种子点）  
(3)接下来，我们要移动种子点到属于他的“点群”的中心。（见图上的第三步）。  
(4)然后重复第2）和第3）步，直到，种子点没有移动（我们可以看到图中的第四步上面的种子点聚合了A,B,C，下面的种子点聚合了D，E）。  

### 33.3.5 K-means算法存在的问题  
K-means 算法的特点——采用两阶段反复循环过程算法，结束的条件是不再有数据元素被重新分配：  

指定聚类：  
即指定数据到某一个聚类，使得它与这个聚类中心的距离比它到其它聚类中心的距离要近。  

修改聚类中心：  
优点：本算法确定的K个划分到达平方误差最小。当聚类是密集的，且类与类之间区别明显时，效果较好。对于处理大数据集，这个算法是相对可伸缩和高效的，计算的复杂度为O(NKt)，其中N是数据对象的数目，t是迭代的次数。一般来说，K<<N，t<<N。  

### 33.3.6 K-means算法优点  
K-means聚类算法的优点主要集中在:  
(1)算法快速、简单；  
(2)对大数据集有较高的效率并且是可伸缩性的；  
(3)时间复杂度近于线性，而且适合挖掘大规模数据集。K-means聚类算法的时间复杂度是O(nkt) ,其中n代表数据集中对象的数量，t代表着算法迭代的次数，k代表着簇的数目。  

### 33.3.7 K-means算法缺点  
在K-means算法中K是事先给定的，这个K值的选定是非常难以估计的。很多时候，事先并不知道给定的数据集应该分成多少个类别才最合适。这也是K-means算法的一个不足。有的算法是通过类的自动合并和分裂，得到较为合理的类型数目K，例如ISODATA算法。关于K-means算法中聚类数目K值的确定在文献中，是根据方差分析理论，应用混合F统计量来确定最佳分类数，并应用了模糊划分熵来验证最佳分类数的正确性。在文献中，使用了一种结合全协方差矩阵的RPCL算法，并逐步删除那些只包含少量训练数据的类。而文献中使用的是一种称为次胜者受罚的竞争学习规则，来自动决定类的适当数目。它的思想是：对每个输入而言，不仅竞争获胜单元的权值被修正以适应输入值，而且对次胜单元采用惩罚的方法使之远离输入值。  

在K-means算法中，首先需要根据初始聚类中心来确定一个初始划分，然后对初始划分进行优化。这个初始聚类中心的选择对聚类结果有较大的影响，一旦初始值选择的不好，可能无法得到有效的聚类结果，这也成为K-means算法的一个主要问题。对于该问题的解决，许多算法采用遗传算法（GA），例如文献中采用遗传算法（GA）进行初始化，以内部聚类准则作为评价指标。  

从K-means算法框架可以看出，该算法需要不断地进行样本分类调整，不断地计算调整后的新的聚类中心，因此当数据量非常大时，算法的时间开销是非常大的。所以需要对算法的时间复杂度进行分析、改进，提高算法应用范围。在文献中从该算法的时间复杂度进行分析考虑，通过一定的相似性准则来去掉聚类中心的侯选集。而在文献中，使用的 K-means 算法是对样本数据进行聚类，无论是初始点的选择还是一次迭代完成时对数据的调整，都是建立在随机选取的样本数据的基础之上，这样可以提高算法的收敛速度。  

### 33.3.8 K-means算法应用  
看到这里，你会说，K-means算法看来很简单，而且好像就是在玩坐标点，没什么真实用处。而且，这个算法缺陷很多，还不如人工呢。是的，前面的例子只是玩二维坐标点，的确没什么意思。但是你想一下下面的几个问题：  
(1)如果不是二维的，是多维的，如5维的，那么，就只能用计算机来计算了。  
(2)二维坐标点的X, Y 坐标，其实是一种向量，是一种数学抽象。现实世界中很多属性是可以抽象成向量的，比如，我们的年龄，我们的喜好，我们的商品，等等，能抽象成向量的目的就是可以让计算机知道某两个属性间的距离。如：我们认为，18岁的人离24岁的人的距离要比离12岁的距离要近等等。  

只要能把现实世界的物体的属性抽象成向量，就可以用K-means算法来归类了。  

## 33.4 实验步骤
这次选用的镜像是demo3,spark集成镜像。  

### 33.4.1 安装mahout  
[下载链接](http://archive.apache.org/dist/mahout/)  

网上的教程比较多是0.9版本的，这次下载的是0.9版本的。解压至/usr/local/mahout目录下即可:  
```
root@master:~# tar -zxvf mahout-distribution-0.9.tar.gz
root@master:~# mv mahout-distribution-0.9 /usr/local/mahout  
root@master:~# cd /usr/local/mahout/
root@master:/usr/local/mahout# ls
LICENSE.txt  bin   examples                 mahout-core-0.9.jar          mahout-integration-0.9.jar
NOTICE.txt   conf  lib                      mahout-examples-0.9-job.jar  mahout-math-0.9.jar
README.txt   docs  mahout-core-0.9-job.jar  mahout-examples-0.9.jar
```  
mahout-examples-0.9-job.jar就是之后我们使用k-means所要用到的jar包。  

修改环境变量, **vim /etc/profile**  
```
export MAHOUT_HOME=/usr/local/mahout
export PATH=$PATH:$MAHOUT_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.7.jar:$MAHOUT_HOME/lib
```  
在CLASSPATH处新增 $MAHOUT_HOME/lib  

修改完后source /etc/profile生效即可  

输入命令 mahout -help查看安装是否成功:  
```
root@master:~# mahout -help
```  
成功则可看到提供的各种算法。

### 33.4.2 实验数据准备  
测试数据链接为:http://archive.ics.uci.edu/ml/databases/synthetic_control/synthetic_control.data  
**数据集为600个60维的集群**  

下载数据集，创建HDFS目录，上传:  
```  
root@master:/usr/local/mahout# wget http://archive.ics.uci.edu/ml/databases/synthetic_control/synthetic_control.data
root@master:/usr/local/mahout# hadoop fs -mkdir -p /user/root/testdata  
root@master:/usr/local/mahout# hadoop fs -put ~/synthetic_control.data /user/root/testdata
```  

### 33.4.3 提交Mahout的K-means程序  
进入mahout的安装目录执行:  
```
root@master:/usr/local/mahout# hadoop jar mahout-examples-0.9-job.jar org.apache.mahout.clustering.syntheticcontrol.kmeans.Job
```
算法的执行过程需要几分钟时间,分成了11个mapreduce任务  

## 33.5 实验结果  
```  
root@master:/usr/local/mahout# hadoop fs -ls /user/root/output
Found 15 items
-rw-r--r--   2 root supergroup        194 2018-08-14 03:56 /user/root/output/_policy
drwxr-xr-x   - root supergroup          0 2018-08-14 03:56 /user/root/output/clusteredPoints
drwxr-xr-x   - root supergroup          0 2018-08-14 03:52 /user/root/output/clusters-0
drwxr-xr-x   - root supergroup          0 2018-08-14 03:53 /user/root/output/clusters-1
drwxr-xr-x   - root supergroup          0 2018-08-14 03:56 /user/root/output/clusters-10-final
drwxr-xr-x   - root supergroup          0 2018-08-14 03:53 /user/root/output/clusters-2
drwxr-xr-x   - root supergroup          0 2018-08-14 03:53 /user/root/output/clusters-3
drwxr-xr-x   - root supergroup          0 2018-08-14 03:54 /user/root/output/clusters-4
drwxr-xr-x   - root supergroup          0 2018-08-14 03:54 /user/root/output/clusters-5
drwxr-xr-x   - root supergroup          0 2018-08-14 03:54 /user/root/output/clusters-6
drwxr-xr-x   - root supergroup          0 2018-08-14 03:55 /user/root/output/clusters-7
drwxr-xr-x   - root supergroup          0 2018-08-14 03:55 /user/root/output/clusters-8
drwxr-xr-x   - root supergroup          0 2018-08-14 03:55 /user/root/output/clusters-9
drwxr-xr-x   - root supergroup          0 2018-08-14 03:52 /user/root/output/data
drwxr-xr-x   - root supergroup          0 2018-08-14 03:52 /user/root/output/random-seeds  
root@master:/usr/local/mahout# hadoop fs -ls /user/root/output/clusters-1
Found 3 items
-rw-r--r--   2 root supergroup          0 2018-08-14 03:53 /user/root/output/clusters-1/_SUCCESS
-rw-r--r--   2 root supergroup        194 2018-08-14 03:53 /user/root/output/clusters-1/_policy
-rw-r--r--   2 root supergroup       7581 2018-08-14 03:53 /user/root/output/clusters-1/part-r-00000
```  

这时直接查看part-r-00000里的结果会出现大堆乱码:  
```
root@master:/usr/local/mahout# hadoop fs -cat /user/root/output/clusters-1/p*
SEQ org.apache.hadoop.io.IntWritable5org.apache.mahout.clustering.iterator.ClusterWritable��Q%��k8y�$�D��0�+org.apache.mahout.clustering.kmeans.Kluster:org.apache.mahout.common.distance.EuclideanDistanceMeasure

�nJ@="#|{/3@.͞F��$@=H_�{��                         <<@?P}��@=�Yq:�"@;Ӑ����@=�~��� @>r�0�?�@?�G�5@=};�@=�6Je�@>?�Qo�@;�f����@>�
                           @=X��W@?q��4G�:@'ub
@>��Av'                                        �
```  

解决办法是将其转换成可读模式:  
```
root@master:/usr/local/mahout/bin# mahout seqdumper -i /user/root/output/clusters-1/part-r-00000 -o ~/result  
root@master:/usr/local/mahout/bin# cat ~/result 
Input Path: /user/root/output/clusters-1/part-r-00000
Key class: class org.apache.hadoop.io.IntWritable Value Class: class org.apache.mahout.clustering.iterator.ClusterWritable
Key: 0: Value: org.apache.mahout.clustering.iterator.ClusterWritable@1ead6e20
Key: 1: Value: org.apache.mahout.clustering.iterator.ClusterWritable@1ead6e20
Key: 2: Value: org.apache.mahout.clustering.iterator.ClusterWritable@1ead6e20
Key: 3: Value: org.apache.mahout.clustering.iterator.ClusterWritable@1ead6e20
Key: 4: Value: org.apache.mahout.clustering.iterator.ClusterWritable@1ead6e20
Key: 5: Value: org.apache.mahout.clustering.iterator.ClusterWritable@1ead6e20
Count: 6
```  

`mahout seqdumper -i /user/root/output/clusters-1/part-r-00000 -o ~/result`  
-i 指定输入路径  -o 指定输出路径  









