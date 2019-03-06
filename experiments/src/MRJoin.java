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
                    String desc = values.iterator().next().toString();
                    while (values.iterator().hasNext()) {
                    context.write(pid, new Text(values.iterator().next().toString() + "\t" + desc));
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