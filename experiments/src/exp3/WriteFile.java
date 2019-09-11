import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
public class WriteFile {
    public static void main(String[] args)throws Exception{
    Configuration conf=new Configuration();
    FileSystem hdfs = FileSystem.get(conf); 
    Path dfs = new Path("/weather.txt"); 
    FSDataOutputStream outputStream = hdfs.create(dfs); 
    outputStream.writeUTF("nj 20161009 23\n");
    outputStream.close();
    }
}