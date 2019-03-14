# 实验二十一 ZooKeeper进程协作

## 21.1 实验目的
掌握Java代码如何连接ZooKeeper集群及通过代码读写ZooKeeper集群的目录下的数据，掌握ZooKeeper如何实现多个线程间的协作。  

## 21.2 实验要求  
用Java代码实现两个线程，一个向ZooKeeper中某一目录中写入数据，另一线程监听此目录，若目录下数据有更新则将目录中数据读取并显示出来。  

## 21.3 实验原理
通过ZooKeeper实现不同物理机器上的进程间通信。  
场景使用：客户端A需要向客户端B发送一条消息msg1。  
实现方法：客户端A把msg1发送给ZooKeeper集群，然后由客户端B自行去ZooKeeper集群读取msg1。  

## 21.4 实验步骤
本实验主要完成多线程通过ZooKeeper完成彼此间的协作问题，实验过程包含启动集群、编写代码、客户端提交代码三个步骤。  

### 21.4.1 启动Zookeeper集群
启动ZooKeeper集群。具体步骤可以参考实验20。

### 21.4.2 导入jar包
从ZooKeeper安装目录下 `/usr/local/zookeeper/` 将**zookeeper-3.4.10.jar**导出到主机  

其次，从ZooKeeper安装包的lib目录下，将如下jar包导出到主机：  
```
jline-0.9.94.jar  
log4j-1.2.16.jar  
netty-3.10.5.Final.jar  
slf4j-api-1.6.1.jar  
slf4j-log4j12-1.6.1.jar  
```

用IDEA创建项目ZookeeperTest，将6个jar包导入到项目(不会可百度）  
![图](./images/ex21/Screenshot%20from%202018-07-27%2016-56-46.png) 　　

### 21.4.3 编写代码
导入jar包后，创建**类WriteMsg**: (作用是每隔一段时间向/testZk写入一串时间数字,这样就可以监控变化)
```java
import org.apache.zookeeper.ZooKeeper;
import java.util.Date;

public class WriteMsg extends Thread {
    @Override
    public void run(){
        try{
            ZooKeeper zk = new ZooKeeper("master:2181", 500000, null);
            String content = Long.toString(new Date().getTime());

            zk.setData("/testZk", content.getBytes(), -1);
            zk.close();
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
```  

创建**类ReadMsg**  
```java
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooKeeper;

public class ReadMsg {
    public static void main(String[] args) throws Exception{
        final ZooKeeper zk = new ZooKeeper("master:2181", 500000, null);

        Watcher wacher = new Watcher() {
            public void process(WatchedEvent event) {
                if(Event.EventType.NodeDataChanged == event.getType()){
                    byte[] bb;
                    try {
                        bb = zk.getData("/testZk", null, null);
                        System.out.println("/testZk的数据: "+new String(bb));
                    }catch (Exception e){
                        e.printStackTrace();
                    }
                }
            }
        };

        zk.exists("/testZk", wacher);

        while(true){
            Thread.sleep(2000);
            new WriteMsg().start();
            zk.exists("/testZk", wacher);
        }
    }
}
```

### 21.4.4 导出jar包
IDEA导出jar包可参考实验18,19，导出后上传至任一节点。 
实验需要监控 **/testZk**，所以需像实验20一样**先创建/testZk** ,在master节点上创建
```
root@master:/usr/local/zookeeper/bin# ./zkCli.sh -server master:2181,slave-0:2181,slave-1:2181
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 1] create /testZk ""
```

在slave1节点上我们运行jar包:  
```
root@slave1:~# java -jar ZookeeperTest.jar 
log4j:WARN No appenders could be found for logger (org.apache.zookeeper.ZooKeeper).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
/testZk???: 1532681392282
/testZk???: 1532681394285
/testZk???: 1532681396291
/testZk???: 1532681398293
/testZk???: 1532681400297
/testZk???: 1532681402301
/testZk???: 1532681404304
/testZk???: 1532681406307
/testZk???: 1532681408312
/testZk???: 1532681410315
/testZk???: 1532681412319
/testZk???: 1532681414322
/testZk???: 1532681416330
/testZk???: 1532681418333
/testZk???: 1532681420344
/testZk???: 1532681422339
```
我们看到内容都是1532681392282之类的一串数字，我们可以在master节点上通过get查看/testZk内容:  
```
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 8] get /testZk
1532681442366
cZxid = 0x10000008e
ctime = Fri Jul 27 08:49:41 UTC 2018
mZxid = 0x1000000e7
mtime = Fri Jul 27 08:50:42 UTC 2018
pZxid = 0x10000008e
cversion = 0
dataVersion = 28
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 13
numChildren = 0
[zk: master:2181,slave1:2181,slave2:2181(CONNECTED) 9] get /testZk
1532681448374
cZxid = 0x10000008e
ctime = Fri Jul 27 08:49:41 UTC 2018
mZxid = 0x1000000f0
mtime = Fri Jul 27 08:50:48 UTC 2018
pZxid = 0x10000008e
cversion = 0
dataVersion = 31
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 13
numChildren = 0
```

可以看出，数字一直在变化，每次变化后的内容也即时反应在了监控处，实验成功。








