# 实验三HDFS实验：读写HDFS文件

## 3.1 实验目的  
1． 会在Linux环境下编写读写HDFS文件的代码；  
2． 会使用jar命令打包代码；  
3． 会编写HDFS读写程序并运行；

## 3.2 实验要求
实验结束时，每位学生均已搭建HDFS开发环境；编写了HDFS写、读代码；在执行了该写、读程序。通过实验了解HDFS读写文件的调用流程，理解HDFS读写文件的原理。

## 3.3 实验原理
### Java Classpath
Classpath设置的目的，在于告诉Java执行环境，**在哪些目录下可以找到您所要执行的Java程序所需要的类或者包**。

Java执行环境本身就是一个平台，执行于这个平台上的程序是已编译完成的Java程序(Java程序编译完成之后，会以.class文件存在)。如果将Java执行环境比喻为操作系统，如果设置Path变量是为了让操作系统找到指定的工具程序(以Windows来说就是找到.exe文件)，则设置Classpath的目的就是让Java执行环境找到指定的Java程序(也就是.class文件)。

上一节的实验中，我们修改/etc/profile时其实已经一并设置了Classpath，之后我们可以通过实例来看效果。
```
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/common/lib/*
```

## 3.4 实验步骤
### 3.4.1 编写HDFS写程序
在master节点上编辑:``vi WriteFile.java``,复制下列内容:
```java
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
```
实际作用是往HDFS中的weather.txt文件写入数据"nj 20161009 23\n".

### 3.4.2 编译并打包HDFS写程序
(1)通过javac命令编译WriteFile.java:
```
root@hadoop-master:~/test# javac WriteFile.java 
root@hadoop-master:~/test# ls
WriteFile.class  WriteFile.java
```
成功编译，生成了WriteFile.class
(2)通过jar命令打包为hdpAction.jar
```
root@hadoop-master:~/test# jar -cvf hdpAction.jar WriteFile.class
added manifest
adding: WriteFile.class(in = 833) (out= 489)(deflated 41%)
```

### 3.4.3 执行HDFS写程序
使用hadoop jar命令执行刚生成的hdpAction.jar
```
root@hadoop-master:~/test# hadoop jar hdpAction.jar WriteFile 
root@hadoop-master:~/test# hadoop fs -ls /
Found 2 items
-rw-r--r--   2 root supergroup          5 2018-06-23 05:22 /input.txt
-rw-r--r--   2 root supergroup         17 2018-06-23 08:26 /weather.txt
root@hadoop-master:~/test# hadoop fs -cat /weather.txt
nj 20161009 23
```
可看到HDFS下已经生成weather.txt且写入内容**nj 20161009 23**.

### 3.4.4 编写HDFS读程序
在master节点上编辑:``vi ReadFile.java``,复制下列内容:
```java
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
```
目的很明显，就是读取刚写入weather.txt的内容

### 3.4.5 编译并打包HDFS读程序
(1)通过javac命令编译ReadFile.java
```
root@hadoop-master:~/test# javac ReadFile.java 
root@hadoop-master:~/test# ls
ReadFile.class  ReadFile.java  WriteFile.class  WriteFile.java  hdpAction.jar
```
(2)通过jar命令打包为hdpAction2.jar
```
root@hadoop-master:~/test# jar -cvf hdpAction2.jar ReadFile.class
added manifest
adding: ReadFile.class(in = 1093) (out= 597)(deflated 45%)
```
 
### 3.4.6 执行HDFS读程序
使用hadoop jar命令执行刚生成的hdpAction2.jar
```
root@hadoop-master:~/test# hadoop jar hdpAction2.jar ReadFile 
myfile: nj 20161009 23

root@hadoop-master:~/test# 
```
成功读取内容