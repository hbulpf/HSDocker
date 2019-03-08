import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.WritableComparable;

public class IntPair implements WritableComparable<IntPair> {
    private IntWritable first;
    private IntWritable second;
    public void set(IntWritable first, IntWritable second) {
        this.first = first;
        this.second = second;
    }
    //注意：需要添加无参的构造方法，否则反射时会报错。
    public IntPair() {
        set(new IntWritable(), new IntWritable());
    }
    public IntPair(int first, int second) {
        set(new IntWritable(first), new IntWritable(second));
    }
    public IntPair(IntWritable first, IntWritable second) {
        set(first, second);
    }
    public IntWritable getFirst() {
        return first;
    }
    public void setFirst(IntWritable first) {
        this.first = first;
    }
    public IntWritable getSecond() {
        return second;
    }
    public void setSecond(IntWritable second) {
        this.second = second;
    }
    public void write(DataOutput out) throws IOException {
        first.write(out);
        second.write(out);
    }
    public void readFields(DataInput in) throws IOException {
        first.readFields(in);
        second.readFields(in);
    }
    public int hashCode() {
        return first.hashCode() * 163 + second.hashCode();
    }
    public boolean equals(Object o) {
        if (o instanceof IntPair) {
            IntPair tp = (IntPair) o;
            return first.equals(tp.first) && second.equals(tp.second);
        }
        return false;
    }
    public String toString() {
        return first + "\t" + second;
    }
    public int compareTo(IntPair tp) {
        int cmp = first.compareTo(tp.first);
        if (cmp != 0) {
            return cmp;
        }
        return second.compareTo(tp.second);
     }
}