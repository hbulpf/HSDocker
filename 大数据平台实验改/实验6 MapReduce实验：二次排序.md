# 实验六 MapReduce实验：二次排序

**每次实验开始前启动hadoop集群，跟实验五一样先完善好对/etc/profile的配置**

## 6.1 实验目的
基于MapReduce思想，编写SecondarySort程序。

## 6.2 实验要求
要能理解MapReduce编程思想，会编写MapReduce版本二次排序程序，然后将其执行并分析执行过程。

## 6.3 实验原理
MR默认会对键进行排序，然而有的时候我们也有对值进行排序的需求。满足这种需求一是可以在reduce阶段排序收集过来的values，但是，如果有数量巨大的values可能就会导致内存溢出等问题，这就是二次排序应用的场景——将对值的排序也安排到MR计算过程之中，而不是单独来做。    
二次排序就是首先按照第一字段排序，然后再对第一字段相同的行按照第二字段排序，注意不能破坏第一次排序的结果

## 6.4 实验步骤
### 6.4.1 编写程序
程序主要难点在于**排序和聚合**。  

对于排序我们需要定义一个**IntPair类用于数据的存储**，并在IntPair类内部自定义Comparator类以实现第一字段和第二字段的比较。  
对于聚合我们需要定义一个FirstPartitioner类，在**FirstPartitioner类内部指定聚合规则为第一字段**。此外，我们还需要开启MapReduce框架自定义**Partitioner功能**和**GroupingComparator功能**。

IntPair类：  
```java
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.WritableComparable;

public class IntPair implements WritableComparable<IntPair> {
    private IntWritable first;
    private IntWritable second;
    public void set(IntWritable first, IntWritable second) {
        this.first = first;
        this.second = second;
    }
    //注意：需要添加无参的构造方法，否则反射时会报错。
    public IntPair() {
        set(new IntWritable(), new IntWritable());
    }
    public IntPair(int first, int second) {
        set(new IntWritable(first), new IntWritable(second));
    }
    public IntPair(IntWritable first, IntWritable second) {
        set(first, second);
    }
    public IntWritable getFirst() {
        return first;
    }
    public void setFirst(IntWritable first) {
        this.first = first;
    }
    public IntWritable getSecond() {
        return second;
    }
    public void setSecond(IntWritable second) {
        this.second = second;
    }
    public void write(DataOutput out) throws IOException {
        first.write(out);
        second.write(out);
    }
    public void readFields(DataInput in) throws IOException {
        first.readFields(in);
        second.readFields(in);
    }
    public int hashCode() {
        return first.hashCode() * 163 + second.hashCode();
    }
    public boolean equals(Object o) {
        if (o instanceof IntPair) {
            IntPair tp = (IntPair) o;
            return first.equals(tp.first) && second.equals(tp.second);
        }
        return false;
    }
    public String toString() {
        return first + "\t" + second;
    }
    public int compareTo(IntPair tp) {
        int cmp = first.compareTo(tp.first);
        if (cmp != 0) {
            return cmp;
        }
        return second.compareTo(tp.second);
     }
}
```

SecondarySort：  
```java
import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
 
public class SecondarySort {
    static class TheMapper extends Mapper<LongWritable, Text, IntPair, NullWritable> {
        @Override
        protected void map(LongWritable key, Text value, Context context)
                throws IOException, InterruptedException {
            String[] fields = value.toString().split("\t");
            int field1 = Integer.parseInt(fields[0]);
            int field2 = Integer.parseInt(fields[1]);
            context.write(new IntPair(field1,field2), NullWritable.get());
        }
    }
    static class TheReducer extends Reducer<IntPair, NullWritable,IntPair, NullWritable> {
        //private static final Text SEPARATOR = new Text("------------------------------------------------");
        @Override
        protected void reduce(IntPair key, Iterable<NullWritable> values, Context context)
                throws IOException, InterruptedException {
            context.write(key, NullWritable.get());
        }
    }
    public static class FirstPartitioner extends Partitioner<IntPair, NullWritable> {
        public int getPartition(IntPair key, NullWritable value,
                int numPartitions) {
            return Math.abs(key.getFirst().get()) % numPartitions;
        }
    }
    //如果不添加这个类，默认第一列和第二列都是升序排序的。
    //这个类的作用是使第一列升序排序，第二列降序排序
    public static class KeyComparator extends WritableComparator {
        //无参构造器必须加上，否则报错。
        protected KeyComparator() {
            super(IntPair.class, true);
        }
        public int compare(WritableComparable a, WritableComparable b) {
            IntPair ip1 = (IntPair) a;
            IntPair ip2 = (IntPair) b;
            //第一列按升序排序
            int cmp = ip1.getFirst().compareTo(ip2.getFirst());
            if (cmp != 0) {
                return cmp;
            }
            //在第一列相等的情况下，第二列按倒序排序
            return -ip1.getSecond().compareTo(ip2.getSecond());
        }
    }
    //入口程序
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf);
        job.setJarByClass(SecondarySort.class);
        //设置Mapper的相关属性
        job.setMapperClass(TheMapper.class);
        //当Mapper中的输出的key和value的类型和Reduce输出的key和value的类型相同时，以下两句可以省略。
        //job.setMapOutputKeyClass(IntPair.class);
        //job.setMapOutputValueClass(NullWritable.class);
        FileInputFormat.setInputPaths(job, new Path(args[0]));
        //设置分区的相关属性
        job.setPartitionerClass(FirstPartitioner.class);
        //在map中对key进行排序
        job.setSortComparatorClass(KeyComparator.class);
        //job.setGroupingComparatorClass(GroupComparator.class);
        //设置Reducer的相关属性
        job.setReducerClass(TheReducer.class);
        job.setOutputKeyClass(IntPair.class);
        job.setOutputValueClass(NullWritable.class);
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        //设置Reducer数量
        int reduceNum = 1;
        if(args.length >= 3 && args[2] != null){
            reduceNum = Integer.parseInt(args[2]);
        }
        job.setNumReduceTasks(reduceNum);
        job.waitForCompletion(true);
    }
}
```

创建两个java文件Intpair.java, SecondarySort.java,复制上面的代码。
**同时**编译两个java文件:  
```
root@hadoop-master:~/expriment6# javac IntPair.java SecondarySort.java 
root@hadoop-master:~/expriment6# ls
IntPair.class                         SecondarySort$TheMapper.class
IntPair.java                          SecondarySort$TheReducer.class
SecondarySort$FirstPartitioner.class  SecondarySort.class
SecondarySort$KeyComparator.class     SecondarySort.java
```
(SecondarySort里面有用到Intpair，单独编译会报错)

### 6.4.2 打包代码
jar命令打包几个.class文件:  
```
root@hadoop-master:~/expriment6# jar -cvf SecondarySort.jar *.class
added manifest
adding: IntPair.class(in = 2171) (out= 990)(deflated 54%)
adding: SecondarySort$FirstPartitioner.class(in = 871) (out= 460)(deflated 47%)
adding: SecondarySort$KeyComparator.class(in = 779) (out= 455)(deflated 41%)
adding: SecondarySort$TheMapper.class(in = 1689) (out= 681)(deflated 59%)
adding: SecondarySort$TheReducer.class(in = 1306) (out= 524)(deflated 59%)
adding: SecondarySort.class(in = 1798) (out= 943)(deflated 47%)
```

### 6.4.3 编写输入数据并执行jar包
创建输入数据文件**secsortdata.txt**，内容如下("\t"作分割):  
```
root@hadoop-master:~/expriment6# vi secsortdata.txt
root@hadoop-master:~/expriment6# cat secsortdata.txt 
7	444
3	9999
7	333
4	22
3	7777
7	555
3	6666
6	0
3	8888
4	11
```

上传输入文件至HDFS:
```
root@hadoop-master:~/expriment6# hadoop fs -put secsortdata.txt /
root@hadoop-master:~/expriment6# hadoop fs -ls /
Found 1 items
-rw-r--r--   2 root supergroup         60 2018-07-06 04:49 /secsortdata.txt
```


执行mapreduce任务：
```
root@hadoop-master:~/expriment6# hadoop jar SecondarySort.jar SecondarySort /secsortdata.txt /output 1
```

## 6.5 实验结果
```
root@hadoop-master:~/expriment6# hadoop fs -ls /output
Found 2 items
-rw-r--r--   2 root supergroup          0 2018-07-06 04:50 /output/_SUCCESS
-rw-r--r--   2 root supergroup         60 2018-07-06 04:50 /output/part-r-00000
root@hadoop-master:~/expriment6# hadoop fs -cat /output/part-r-00000
3	9999
3	8888
3	7777
3	6666
4	22
4	11
6	0
7	555
7	444
7	333
```

可看到成功实现二次排序，第一列升序，第二列降序。
