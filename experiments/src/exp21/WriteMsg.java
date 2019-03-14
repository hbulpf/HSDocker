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