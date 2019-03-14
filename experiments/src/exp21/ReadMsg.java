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