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
        configuration.set("hbase.zookeeper.quorum", "master:2181,slave-0:2181,slave-1:2181");
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

                //列簇 , 列名, 值
                put.addColumn("c1".getBytes(), "c1tofamily1".getBytes(), ("aaa"+i).getBytes());
                put.addColumn("c1".getBytes(), "c2tofamily1".getBytes(), ("bbb"+i).getBytes());
                put.addColumn("c2".getBytes(), "c1tofamily2".getBytes(), ("ccc"+i).getBytes());
                putList.add(put);
            }
            table.put(putList);
            table.close();

            //查询数据，代码实现
            //Scan 对象
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