import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

public class ReadFile {
  public static void main(String[] args) throws IOException {
    Configuration conf = new Configuration();
    Path inFile = new Path("/weather.txt");
    FileSystem hdfs = FileSystem.get(conf);
    FSDataInputStream inputStream = hdfs.open(inFile);
    System.out.println("myfile: " + inputStream.readUTF());
    inputStream.close();
   }
}