# 实验八  MapReduce实验：Join操作

## 8.1 实验目的
基于MapReduce思想，编写两文件Join操作的程序。

## 8.2 实验要求
能够理解MapReduce编程思想，然后会编写MapReduce版本Join程序，并能执行该程序和分析执行过程。

## 8.3 实验背景
### 8.3.1 概述
对于RDBMS中的Join操作大伙一定非常熟悉，写SQL的时候要十分注意细节，稍有差池就会耗时巨久造成很大的性能瓶颈，而在Hadoop中使用MapReduce框架进行Join的操作时同样耗时，但是由于Hadoop的分布式设计理念的特殊性，因此对于这种Join操作同样也具备了一定的特殊性。

### 8.3.2 原理
使用MapReduce实现Join操作有多种实现方式：  

在**Reduce端连接**为最为常见的模式：  

Map端的主要工作：为来自不同表(文件)的key/value对打标签以区别不同来源的记录。然后用**连接字段作为key**，**其余部分和新加的标志作为value**，最后进行输出。  

Reduce端的主要工作：在Reduce端以连接字段作为key的分组已经完成，我们只需要在每一个分组当中将那些来源于不同文件的记录(在map阶段已经打标志)分开，最后进行笛卡尔只就OK了。

在Map端进行连接:  
使用场景：一张表十分小、一张表很大。  
用法:在提交作业的时候先将小表文件放到该作业的DistributedCache中，然后从DistributeCache中取出该小表进行Join key / value解释分割放到内存中(可以放大Hash Map等等容器中)。然后扫描大表，看大表中的每条记录的Join key /value值是否能够在内存中找到相同Join key的记录，如果有则直接输出结果。

SemiJoin：  
SemiJoin就是所谓的半连接，其实仔细一看就是Reduce Join的一个变种，就是在map端过滤掉一些数据，在网络中只传输参与连接的数据不参与连接的数据不必在网络中进行传输，从而减少了shuffle的网络传输量，使整体效率得到提高，其他思想和Reduce Join是一模一样的。说得更加接地气一点就是将小表中参与Join的key单独抽出来通过DistributedCach分发到相关节点，然后将其取出放到内存中(可以放到HashSet中)，在map阶段扫描连接表，将Join key不在内存HashSet中的记录过滤掉，让那些参与Join的记录通过shuffle传输到Reduce端进行Join操作，其他的和Reduce Join都是一样的

## 8.4 实验步骤
### 8.4.1 准备阶段
在这里我们介绍最为常见的在Reduce端连接的代码编写流程。
首先准备数据，数据分为两个文件，分别为A表和B表数据:  

A表数据:  
```
201001  1003    abc
201002  1005    def
201003  1006    ghi
201004  1003    jkl
201005  1004    mno
201006  1005    pqr
```

B表数据:  
```
1003    kaka
1004    da
1005    jue
1006    zhao
```
现在要通过程序得到A表第二个字段和B表第一个字段一致的数据的Join结果：  
```
1003    201001  abc kaka
1003    201004  jkl kaka
1004    201005  mno da
1005    201002  def jue
1005    201006  pqr jue
1006    201003  ghi zhao
```

程序分析执行过程如下：

在map阶段，把所有记录标记成<key,value\>的形式，其中key是1003/1004/1005/1006的字段值，value则根据来源不同取不同的形式：来源于表A的记录，value的值为“201001 abc”等值；来源于表B的记录，value的值为”kaka“之类的值。
在Reduce阶段，先把每个key下的value列表拆分为分别来自表A和表B的两部分，分别放入两个向量中。然后遍历两个向量做笛卡尔积，形成一条条最终结果。

### 8.4.2 编写程序
完整代码：  
```java
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
 
import java.util.Vector;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import org.apache.hadoop.util.GenericOptionsParser;
 
public class MRJoin {
public static class MR_Join_Mapper extends Mapper<LongWritable, Text, TextPair, Text> {
        @Override
            protected void map(LongWritable key, Text value, Context context)
                                                throws IOException, InterruptedException {
                    // 获取输入文件的全路径和名称
                    String pathName = ((FileSplit) context.getInputSplit()).getPath().toString();
                    if (pathName.contains("data.txt")) {
                            String values[] = value.toString().split("\t");
                            if (values.length < 3) {
                                // data数据格式不规范，字段小于3，抛弃数据
                                    return;
                            } else {
                                // 数据格式规范，区分标识为1
                                TextPair tp = new TextPair(new Text(values[1]), new Text("1"));
                                context.write(tp, new Text(values[0] + "\t" + values[2]));
                            }
                    }
                    if (pathName.contains("info.txt")) {
                            String values[] = value.toString().split("\t");
                            if (values.length < 2) {
                                    // data数据格式不规范，字段小于2，抛弃数据
                                    return;
                        } else {
                            // 数据格式规范，区分标识为0
                            TextPair tp = new TextPair(new Text(values[0]), new Text("0"));
                            context.write(tp, new Text(values[1]));
                            }
                }
        }
}
 
 //这个是分组　map得到的数据，根据第一字段进行分组
public static class MR_Join_Partitioner extends Partitioner<TextPair, Text> {
            @Override
            public int getPartition(TextPair key, Text value, int numParititon) {
                    return Math.abs(key.getFirst().hashCode() * 127) % numParititon;
            }
}
 
 //分完组后进行排序，确保A表的数据在各个组里为第一个
public static class MR_Join_Comparator extends WritableComparator {
            public MR_Join_Comparator() {
                    super(TextPair.class, true);
            }
 
            public int compare(WritableComparable a, WritableComparable b) {
                    TextPair t1 = (TextPair) a;
                    TextPair t2 = (TextPair) b;
                    return t1.getFirst().compareTo(t2.getFirst());
        }
}
 
public static class MR_Join_Reduce extends Reducer<TextPair, Text, Text, Text> {
        protected void Reduce(TextPair key, Iterable<Text> values, Context context)
                            throws IOException, InterruptedException {
                    Text pid = key.getFirst();
                    Vector<String> vectorA = new Vector<String>();
                    for (Text val : values){
                        	vectorA.add(val.toString());
                    }
                    /*String desc = values.iterator().next().toString();
                    while (values.iterator().hasNext()) {
                    context.write(pid, new Text(values.iterator().next().toString() + "\t" + desc));
                    }*/
                    int sizeA = vectorA.size();
                    for( int i=0 ; i<sizeA ; i++){
                        //context.write(pid, new Text(vectorA.indexOf(i)+"\t"+vectorA.indexOf(0)));
                        context.write(new Text("a"), new Text(vectorA.indexOf(i)));
                    }
                 }
            
}


public static void main(String agrs[])
                throws IOException, InterruptedException, ClassNotFoundException {
            Configuration conf = new Configuration();
            GenericOptionsParser parser = new GenericOptionsParser(conf, agrs);
            String[] otherArgs = parser.getRemainingArgs();
            if (agrs.length < 3) {
                    System.err.println("Usage: MRJoin <in_path_one> <in_path_two> <output>");
                    System.exit(2);
            }
    
            Job job = new Job(conf, "MRJoin");
            // 设置运行的job
            job.setJarByClass(MRJoin.class);
            // 设置Map相关内容
            job.setMapperClass(MR_Join_Mapper.class);
            // 设置Map的输出
            job.setMapOutputKeyClass(TextPair.class);
            job.setMapOutputValueClass(Text.class);
            // 设置partition
            job.setPartitionerClass(MR_Join_Partitioner.class);
            // 在分区之后按照指定的条件分组
            job.setGroupingComparatorClass(MR_Join_Comparator.class);
            // 设置Reduce
            job.setReducerClass(MR_Join_Reduce.class);
            // 设置Reduce的输出
            job.setOutputKeyClass(Text.class);
            job.setOutputValueClass(Text.class);
            // 设置输入和输出的目录
            FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
            FileInputFormat.addInputPath(job, new Path(otherArgs[1]));
            FileOutputFormat.setOutputPath(job, new Path(otherArgs[2]));
            // 执行，直到结束就退出
            System.exit(job.waitForCompletion(true) ? 0 : 1);
 }
}

class TextPair implements WritableComparable<TextPair> {
    private Text first;
    private Text second;

    public TextPair() {
            set(new Text(), new Text());
    }
 
    public TextPair(String first, String second) {
            set(new Text(first), new Text(second));
    }
 
    public TextPair(Text first, Text second) {
            set(first, second);
    }
 
    public void set(Text first, Text second) {
            this.first = first;
            this.second = second;
    }
 
    public Text getFirst() {
            return first;
    }
 
    public Text getSecond() {
            return second;
    }
 
    public void write(DataOutput out) throws IOException {
            first.write(out);
            second.write(out);
    }
 
public void readFields(DataInput in) throws IOException {
            first.readFields(in);
            second.readFields(in);
    }
 
public int compareTo(TextPair tp) {
            int cmp = first.compareTo(tp.first);
            if (cmp != 0) {
                    return cmp;
            }
            return second.compareTo(tp.second);
    }
}
```

打包成jar包:  
```
root@hadoop-master:~/expriment7# jar -cvf MRJoin.jar *.class
added manifest
adding: MRJoin$MR_Join_Comparator.class(in = 657) (out= 383)(deflated 41%)
adding: MRJoin$MR_Join_Mapper.class(in = 2236) (out= 960)(deflated 57%)
adding: MRJoin$MR_Join_Partitioner.class(in = 783) (out= 448)(deflated 42%)
adding: MRJoin$MR_Join_Reduce.class(in = 1607) (out= 735)(deflated 54%)
adding: MRJoin.class(in = 2191) (out= 1132)(deflated 48%)
adding: TextPair.class(in = 1500) (out= 746)(deflated 50%)
```


### 8.4.3 准备输入文件并执行jar包
创建输入文件**data.txt**存放Ａ表数据(文件名不可变)
```
root@hadoop-master:~/expriment7# vi data.txt
root@hadoop-master:~/expriment7# cat data.txt
201001	1003    abc
201002	1005	def
201003	1006	ghi
201004	1003	jkl
201005	1004	mno
201006	1005	pqr
```
创建输入文件**info.txt**存放Ｂ表数据:
```
root@hadoop-master:~/expriment7# vi info.txt
root@hadoop-master:~/expriment7# cat info.txt
1003	kaka
1004	da
1005	jue
1006	zhao
```

上传文件至HDFS:
```
root@hadoop-master:~/expriment7# hadoop fs -put data.txt /
root@hadoop-master:~/expriment7# hadoop fs -put info.txt /
root@hadoop-master:~/expriment7# hadoop fs -ls /
Found 2 items
-rw-r--r--   2 root supergroup         96 2018-07-06 07:46 /data.txt
-rw-r--r--   2 root supergroup         37 2018-07-06 07:46 /info.txt
```

执行mapreduce任务:  
```
root@hadoop-master:~/expriment7# hadoop jar MRJoin.jar MRJoin /data.txt /info.txt /output
```

## 8.5 实验结果
**!!Reduce结果错误，尚未解决!!**
```
root@hadoop-master:~/experiment77# hadoop fs -cat /output/p*
TextPair@1e2161df	kaka
TextPair@1e2161df	201004	jkl
TextPair@1e2161df	da
TextPair@1e2161df	201005	mno
TextPair@1e2161df	jue
TextPair@1e2161df	201006	pqr
TextPair@1e2161df	201002	def
TextPair@1e2161df	zhao
TextPair@1e2161df	201003	ghi
```