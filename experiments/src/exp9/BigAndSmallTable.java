import java.io.IOException;
import java.util.HashSet;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.LineReader;

public class BigAndSmallTable {
        public static class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable> {
        private final static IntWritable one = new IntWritable(1);
        private static HashSet<String> smallTable = null;

        protected void setup(Context context) throws IOException, InterruptedException {
            smallTable = new HashSet<String>();
            Path smallTablePath = new Path(context.getConfiguration().get("smallTableLocation"));
            FileSystem hdfs = smallTablePath.getFileSystem(context.getConfiguration());
            FSDataInputStream hdfsReader = hdfs.open(smallTablePath);
            Text line = new Text();
            LineReader lineReader = new LineReader(hdfsReader);
            while (lineReader.readLine(line) > 0) {
            // you can do something here
            String[] values = line.toString().split(" ");
            for (int i = 0; i < values.length; i++) {
                 smallTable.add(values[i]);
                 System.out.println(values[i]);
            }
        }
        lineReader.close();
        hdfsReader.close();
        System.out.println("setup ok *^_^* ");
    }

public void map(Object key, Text value, Context context) 
                    throws IOException, InterruptedException {
                String[] values = value.toString().split(" ");
                for (int i = 0; i < values.length; i++) {
                    if (smallTable.contains(values[i])) {
                        context.write(new Text(values[i]), one);
                    }
                }
        }
}

public static class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
        private IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<IntWritable> values,
                Context context) throws IOException, InterruptedException {
                    int sum = 0;
                    for (IntWritable val : values) {
                        sum += val.get();
                    }
                    result.set(sum);
                    context.write(key, result);
        }
}

public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        conf.set("smallTableLocation", args[1]);
        Job job = Job.getInstance(conf, "BigAndSmallTable");
        job.setJarByClass(BigAndSmallTable.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setReducerClass(IntSumReducer.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[2]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}