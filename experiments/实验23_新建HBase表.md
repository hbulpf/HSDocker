# 实验二十三 新建HBase表

## 23.1 实验目的  
1.掌握HBase数据模型(逻辑模型及物理模型);  
2.掌握如何使用Java代码获得HBase连接，并熟练Java对HBase数据库的基本操作，进一步加深对HBase表概念的理解。  

## 23.2 实验要求  
通过Java代码实现与HBase数据库连接，然后用Java API创建HBase表，向创建的表中写数据，最后将表中数据读取出来并展示。  

## 23.3 实验原理  
逻辑模型：HBase以表的形式存储数据，每个表由行和列组成，每个列属于一个特定的列族(Column Family)。**表中的行和列确定的存储单元称为一个元素(Cell)，每个元素保存了同一份数据的多个版本，由时间戳(Time Stamp)来标识**。**行健是数据行在表中的唯一标识，并作为检索记录的主键**。在HBase中访问表中的行只有三种方式：通过单个行健访问、给定行键的范围扫描、全表扫描。行健可以是任意字符串，默认按字段顺序存储。表中的列定义为: <family>:<qualifier>(<列族>:<限定符>)，通过列族和限定符两部分可以唯一指定一个数据的存储列。元素由行健、列(<列族>:<限定符>)和时间戳唯一确定，**元素中的数据以字节码的形式存储，没有类型之分**。  

物理模型：HBase是按照列存储的稀疏行/列矩阵，其物理模型实际上就是把概念模型中的一个行进行分割，并按照列族存储。  

## 23.4 实验步骤  
本实验主要演示HBase Java API的一些基本操作，**包括取得链接，创建表，写数据，查询等几个步骤**，具体内容如下：  

首先，启动HBase集群(参考实验二十二)。  

其次，从HBase安装包的lib目录导入如下jar包到开发工具(jar包的版本号以实际的安装中的版本号为主)：  
```  
commons-codec-1.9.jar  
commons-collections-3.2.2.jar  
commons-configuration-1.6.jar  
commons-lang-2.6.jar  
commons-logging-1.2.jar  
guava-12.0.1.jar  
hadoop-auth-2.5.1.jar  
hadoop-common-2.5.1.jar  
hadoop-hdfs-2.5.1.jar  
hbase-client-1.2.6.jar  
hbase-common-1.2.6.jar  
hbase-protocol-1.2.6.jar  
htrace-core-3.1.0-incubating.jar  
httpclient-4.2.5.jar  
httpcore-4.4.1.jar  
libthrift-0.9.3.jar  
log4j-1.2.17.jar  
metrics-core-2.2.0.jar  
netty-all-4.0.23.Final.jar  
protobuf-java-2.5.0.jar  
slf4j-api-1.7.7.jar  
slf4j-log4j12-1.7.5.jar  
zookeeper-3.4.6.jar
```  

我使用的是IDEA，创建项目HbaseTest,导入jar包(导入方法自行百度), 创建类Main, 完整代码如下:  
```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.*;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.filter.CompareFilter;
import org.apache.hadoop.hbase.filter.Filter;
import org.apache.hadoop.hbase.filter.FilterList;
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter;
import org.apache.hadoop.hbase.util.Bytes;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class Main {
    public static void main(String[] args){
        
        //获得HBase连接
        Configuration configuration = HBaseConfiguration.create();
        Connection connection;
        configuration.set("hbase.zookeeper.quorum", "master:2181,slave1:2181,slave2:2181");
        configuration.set("zookeeper.znode.parent", "/hbase");

        try{
            connection = ConnectionFactory.createConnection(configuration);
            //获得HBaseAdmin对象
            Admin admin = connection.getAdmin();
            //表名称
            String tn = "mytable";
            TableName tableName = TableName.valueOf(tn);
            //表不存在时创建表
            if(!admin.tableExists(tableName)){
                //创建表描述对象
                HTableDescriptor tableDescriptor = new HTableDescriptor(tableName);
                //列簇1
                HColumnDescriptor columnDescriptor1 = new HColumnDescriptor("c1".getBytes());
                tableDescriptor.addFamily(columnDescriptor1);
                //列簇2
                HColumnDescriptor columnDescriptor2 = new HColumnDescriptor("c2".getBytes());
                tableDescriptor.addFamily(columnDescriptor2);
                //用HBaseAdmin对象创建表
                admin.createTable(tableDescriptor);
            }

            admin.close();
            
            //获得table接口
            Table table = connection.getTable(TableName.valueOf("mytable"));
            
            //添加的数据对象集合
            List<Put> putList = new ArrayList<Put>();
            for(int i=0 ; i<10 ; i++){
                String rowkey = "mykey" + i;
                Put put = new Put(rowkey.getBytes());
                
                //列簇 , 列名, 值
                put.addColumn("c1".getBytes(), "c1tofamily1".getBytes(), ("aaa"+i).getBytes());
                put.addColumn("c1".getBytes(), "c2tofamily1".getBytes(), ("bbb"+i).getBytes());
                put.addColumn("c2".getBytes(), "c1tofamily2".getBytes(), ("ccc"+i).getBytes());
                putList.add(put);
            }
            table.put(putList);
            table.close();

            //查询数据，代码实现
            //Scan 对象
            Scan scan = new Scan();
            //限定rowkey查询范围
            scan.setStartRow("mykey0".getBytes());
            scan.setStopRow("mykey9".getBytes());
            
            //只查询c1：c1tofamily1列
            scan.addColumn("c1".getBytes(), "c1tofamily1".getBytes());
            
            //过滤器集合
            FilterList filterList = new FilterList();
            
            //查询符合条件c1：c1tofamily1==aaa7的记录
            Filter filter1 = new SingleColumnValueFilter("c1".getBytes(), "c1tofamily1".getBytes(),CompareFilter.CompareOp.EQUAL, "aaa7".getBytes());
            filterList.addFilter(filter1);
            scan.setFilter(filterList);
            ResultScanner results = table.getScanner(scan);

            for (Result result : results) {
                System.out.println("获得到rowkey:" + new String(result.getRow()));
                for (Cell cell : result.rawCells()) {
                    System.out.println("列簇：" +
                            Bytes.toString(cell.getFamilyArray(),cell.getFamilyOffset(),cell.getFamilyLength())
                            + "列:" +
                            Bytes.toString(cell.getQualifierArray(),cell.getQualifierOffset(),cell.getQualifierLength())
                            + "值:" +
                            Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
            }

            results.close();
            table.close();


        }catch (IOException e){
            e.printStackTrace();
        }
    }
}
```  

代码完整后，导出jar包(根据开发工具的不同方法也不同，自行解决), 上传至容器master节点: 。  

执行jar包:  
```
root@master:~# java -jar HbaseTest.jar 
log4j:WARN No appenders could be found for logger (org.apache.hadoop.security.Groups).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
???rowkey:mykey7
???c1?:c1tofamily1?:aaa7
```  
出现的乱码,代码里的查询部分结果不太明显，但表确实已经成功创建并插入数据。 

进入hbase shell 查看是否成功创建表并插入数据。  
```
root@master:/usr/local/hbase/bin# ./hbase shell
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/local/hbase/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/local/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
HBase Shell; enter 'help<RETURN>' for list of supported commands.
Type "exit<RETURN>" to leave the HBase Shell
Version 1.2.6, rUnknown, Mon May 29 02:25:32 CDT 2017

hbase(main):001:0> list
TABLE                                                                                                                        
mytable                                                                                                                      
1 row(s) in 0.1450 seconds

=> ["mytable"]  
hbase(main):002:0> scan 'mytable'
ROW                              COLUMN+CELL                                                                                 
 mykey0                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa0                                  
 mykey0                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb0                                  
 mykey0                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc0                                  
 mykey1                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa1                                  
 mykey1                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb1                                  
 mykey1                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc1                                  
 mykey2                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa2                                  
 mykey2                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb2                                  
 mykey2                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc2                                  
 mykey3                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa3                                  
 mykey3                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb3                                  
 mykey3                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc3                                  
 mykey4                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa4                                  
 mykey4                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb4                                  
 mykey4                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc4                                  
 mykey5                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa5                                  
 mykey5                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb5                                  
 mykey5                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc5                                  
 mykey6                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa6                                  
 mykey6                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb6                                  
 mykey6                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc6                                  
 mykey7                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa7                                  
 mykey7                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb7                                  
 mykey7                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc7                                  
 mykey8                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa8                                  
 mykey8                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb8                                  
 mykey8                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc8                                  
 mykey9                          column=c1:c1tofamily1, timestamp=1533021881959, value=aaa9                                  
 mykey9                          column=c1:c2tofamily1, timestamp=1533021881959, value=bbb9                                  
 mykey9                          column=c2:c1tofamily2, timestamp=1533021881959, value=ccc9                                  
10 row(s) in 0.1430 seconds
```  

表"mytable"已成功创建，数据已成功插入，实验成功。








