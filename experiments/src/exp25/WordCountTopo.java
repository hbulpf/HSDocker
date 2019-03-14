package test;

import org.apache.storm.Config;
import org.apache.storm.StormSubmitter;
import org.apache.storm.generated.AlreadyAliveException;
import org.apache.storm.generated.AuthorizationException;
import org.apache.storm.generated.InvalidTopologyException;
import org.apache.storm.topology.TopologyBuilder;

public class WordCountTopo {
    public static void main(String[] args)throws Exception{
        TopologyBuilder builder = new TopologyBuilder();
        builder.setSpout("word-reader", new WordReaderSpout());
        builder.setBolt("word-counter", new WordCounterBolt()).shuffleGrouping("word-reader");
        Config conf = new Config();
        StormSubmitter.submitTopologyWithProgressBar("wordCount", conf,builder.createTopology());
    }
}