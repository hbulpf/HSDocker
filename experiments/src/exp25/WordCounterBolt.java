package cproc.word;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.BasicOutputCollector;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseBasicBolt;
import org.apache.storm.tuple.Tuple;

public class WordCounterBolt extends BaseBasicBolt{
    private static final long serialVersionUID = 5683648523524179434L;
    private HashMap<String, Integer> counters = new HashMap<String, Integer>();
    private volatile boolean edit = false;
    @Override
    public void prepare(Map stormConf, TopologyContext context) {
        new Thread(new Runnable() {
            public void run() {
                while (true) {
                    if (edit) {
                        for (Entry<String, Integer> entry : counters.entrySet())
                        {
                            System.out.println(entry.getKey() + " : " + entry.getValue());
                        }
                        edit = false;
                    }
                    try{
                        Thread.sleep(1000);
                    }catch (InterruptedException e){
                        e.printStackTrace();
                    }
                }
            }
        }).start();
    }

    @Override
    public void execute(Tuple input, BasicOutputCollector collector) {
        String str = input.getString(0);
        if (!counters.containsKey(str)) {
            counters.put(str, 1);
        }else{
            Integer c = counters.get(str) + 1;
            counters.put(str, c);
        }
        edit=true;
    }
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {

    }
}