package cproc.word;

import java.util.Map;
import java.util.Random;
import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;
import org.apache.storm.utils.Utils;

public class WordReaderSpout extends BaseRichSpout{
    private SpoutOutputCollector collector;
    @Override
    public void open(Map conf, TopologyContext context, SpoutOutputCollector collector){
        this.collector = collector;
    }
    @Override
    public void nextTuple() {
        Utils.sleep(1000);
        final String[] words = new String[] {"nathan", "mike", "jackson", "golda", "bertels"};
        Random rand = new Random();
        String word = words[rand.nextInt(words.length)];
        collector.emit(new Values(word));
    }
    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields("word"));
    }
}