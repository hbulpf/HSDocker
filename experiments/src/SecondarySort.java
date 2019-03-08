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