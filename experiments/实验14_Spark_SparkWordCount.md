# 实验十四 Spark实验：SparkWordCount

## 14.1 实验目的
熟悉Scala语言，基于Spark思想，编写SparkWordCount程序。

## 14.2 实验要求
熟悉Scala语言，理解Spark编程思想，并会编写Spark版本的WordCount，然后能够在spark-shell中执行代码和分析执行过程。

## 14.3 实验原理
Scala是一门以Java虚拟机（JVM）为目标运行环境并将面向对象(OO)和函数式编程语言(FP)的最佳特性结合在一起的编程语言。  

它既有动态语言那样的灵活简洁，同时又保留了静态类型检查带来的安全保障和执行效率，加上其强大的抽象能力，既能处理脚本化的临时任务，又能处理高并发场景下的分布式互联网大数据应用，可谓能缩能伸。  

Scala运行在JVM之上，因此它可以访问任何Java类库并且与Java框架进行互操作。其与Java的集成度很高，可以直接使用Java社区大量成熟的技术框架和方案。由于它直接编译成Java字节码，因此我们可以充分利用JVM这个高性能的运行平台。

### 14.3.1 Scala是兼容的
Scala被设计成无缝地与Java实施互操作。不需要你从Java平台后退两步然后跳到Java语言前面去。它允许你在现存代码中加点儿东西——在你已有的东西上建设，Scala程序会被编译为JVM的字节码。它们的执行期性能通常与Java程序一致。Scala代码可以调用Java方法，访问Java字段，继承自Java类和实现Java接口。这些都不需要特别的语法，显式接口描述，或粘接代码。实际上，几乎所有Scala代码都极度依赖于Java库，而程序员无须意识到这点。  

交互式操作的另一个方面是Scala极度重用了Java类型 。Scala的Int类型代表了Java的原始整数类型int，Float代表了float，Boolean代表boolean，等等。Scala的数组被映射到Java数组。Scala同样重用了许多标准Java库类型。例如，Scala里的字串文本”abc”是java.lang.String，而抛出的异常必须是java.lang.Throwable的子类。  

Scala不仅重用了Java的类型，还把它们“打扮”得更漂亮。例如，Scala的字串支持类似于toInt和toFloat的方法，可以把字串转换成整数或者浮点数。因此你可以写str.toInt替代Integer.parseInt(str)。如何在不打破互操作性的基础上做到这点呢？Java的String类当然不会有toInt方法。实际上，Scala有一个解决这种高级库设计和互操作性不相和谐的通用方案。Scala可以让你定义隐式转换：implicit conversion，这常常用在类型失配，或者选用不存在的方法时。在上面的例子里，当在字串中寻找toInt方法时，Scala编译器会发现String类里没有这种方法，但它会发现一个把Java的String转换为Scala的RichString类的一个实例的隐式转换，里面定义了这么个方法。于是在执行toInt操作之前，转换被隐式应用。  

Scala代码同样可以由Java代码调用 。有时这种情况要更加微妙，因为Scala是一种比Java更丰富的语言，有些Scala更先进的特性在它们能映射到Java前需要先被编码一下。

### 14.3.2 Scala是简洁的
Scala程序一般都很短 。Scala程序员曾报告说与Java比起来代码行数可以减少到1/10。这有可能是个极限的例子。较保守的估计大概标准的Scala程序应该有Java写的同样的程序一半行数左右。更少的行数不仅意味着更少的打字工作，同样意味着更少的话在阅读和理解程序上的努力及更少的出错可能。许多因素在减少代码行上起了作用 。Scala的语法避免了一些束缚Java程序的固定写法 。例如，Scala里的分号是可选的，且通常不写。Scala语法里还有很多其他的地方省略了东西。比方说，比较一下你在Java和Scala里是如何写类及构造函数的。

在Java里，带有构造函数的类经常看上去是这个样子：
```java
// 在Java里
class MyClass {
    private int index;
    private String name;
    public MyClass(int index, String name) {
        this.index = index;
        this.name = name;
    }
}
```
在Scala里，你会写成这样：
```
class MyClass(index: Int, name: String)
```
根据这段代码，Scala编译器将制造有两个私有成员变量的类，一个名为index的Int类型和一个叫做name的String类型，还有一个用这些变量作为参数获得初始值的构造函数。这个构造函数还将用作为参数传入的值初始化这两个成员变量。Scala类写起来更快，读起来更容易，最重要的是，比Java类更不容易犯错。

有助于Scala的简洁易懂的另一个因素是它的类型推断 。重复的类型信息可以被忽略，因此程序变得更有条理和易读，但或许减少代码最关键的是因为已经存在于你的库里而不需要写的代码。Scala给了你许多工具来定义强有力的库让你抓住并提炼出通用的行为。例如，库类的不同方面可以被分成若干特质，而这些又可以被灵活地混合在一起。或者，库方法可以用操作符参数化，从而让你有效地定义那些你自己控制的构造。这些构造组合在一起，就能够让库的定义既是高层级的又能灵活运用。

### 14.3.3 Scala是高级的
程序员总是在和复杂性纠缠 。为了高产出的编程，你必须明白你工作的代码。过度复杂的代码成了很多软件工程崩溃的原因。不幸的是，重要的软件往往有复杂的需求。这种复杂性不可避免；必须（由不受控）转为受控。

Scala可以通过让你提升你设计和使用的接口的抽象级别来帮助你管理复杂性 。例如，假设你有一个String变量name，你想弄清楚是否String包含一个大写字符。  

在Java里，你或许这么写：  
```java
// 在Java里
boolean nameHasUpperCase = false;
for (int i = 0; i < name.length(); ++i) {
    if (Character.isUpperCase(name.charAt(i))) {
        nameHasUpperCase = true;
        break;
    }
}
```
在Scala里，你可以写成：  
```
val nameHasUpperCase = name.exists(_.isUpperCase)
```
Java代码把字符串看作循环中逐字符步进的低层级实体。Scala代码把同样的字串当作能用论断：predicate查询的字符高层级序列。明显Scala代码更短并且——对训练有素的眼睛来说——比Java代码更容易懂。因此Scala代码在通盘复杂度预算上能极度地变轻，它也更少给你机会犯错。

论断，_.isUpperCase，是一个Scala里面函数式文本的例子 。它描述了带一个字符参量（用下划线字符代表）的函数，并测试其是否为大写字母 。原则上，这种控制的抽象在Java中也是可能的 ，为此需要定义一个包含抽象功能的方法的接口。例如，如果你想支持对字串的查询，就应引入一个只有一个方法hasProperty的接口CharacterProperty：  
```java
// 在Java里
interface CharacterProperty {
    boolean hasProperty(char ch);
}
```
然后你可以在Java里用这个接口格式实现一个方法exists：它带一个字串和一个CharacterProperty参数，如果字串中有某个字符符合属性，结果返回真。然后你可以这样调用exists：  
```java
// 在Java里
exists(name, new CharacterProperty {
    boolean hasProperty(char ch) {
        return Character.isUpperCase(ch);
    }
});
```
然而，所有这些真的感觉很复杂。复杂到实际上多数Java程序员都不会惹这个麻烦。他们会宁愿写个循环并漠视他们代码里复杂性的累加。另一方面，Scala里的函数式文本真的很轻量，于是就频繁被使用。随着对Scala的逐步了解，你会发现越来越多定义和使用你自己的控制抽象的机会。你将发现这能帮助避免代码重复并因此保持你的程序简短和清晰。

### 14.3.4  Scala是静态类型的
静态类型系统认定变量和表达式与它们持有和计算的值的种类有关 。Scala坚持作为一种具有非常先进的静态类型系统的语言。从Java那样的内嵌类型系统起步，能够让你使用泛型：generics参数化类型，用交集：intersection联合类型和用抽象类型：abstract type隐藏类型的细节。这些为建造和组织你自己的类型打下了坚实的基础，从而能够设计出即安全又能灵活使用的接口。静态类型系统的经典优越性将更被赏识，其中最重要的包括程序抽象的可检验属性，安全的重构，以及更好的文档。

**可检验属性。**静态类型系统可以保证消除某些运行时的错误。例如，可以保证这样的属性：布尔型不会与整数型相加；私有变量不会从类的外部被访问；函数带了正确个数的参数；只有字串可以被加到字串集之中 。不过当前的静态类型系统还不能查到其他类型的错误。比方说，通常查不到无法终结的函数，数组越界，或除零错误。同样也查不到你的程序不符合式样书（假设有这么一份式样书）。静态类型系统因此被认为不是很有用而被忽视。有人认为，既然静态类型系统只能发现简单错误，为什么不用能提供更广泛的覆盖的单元测试呢？尽管静态类型系统确实不能替代单元测试，但是却能减少单元测试的数量。同样，单元测试也不能替代静态类型。总而言之，如Edsger Dijkstra所说，测试只能证明存在错误，而非不存在。因此，静态类型能给的保证或许很简单，但它们是无论多少测试都不能给的真正的保证。  

**安全的重构。**静态类型系统提供了让你具有高度信心改动代码基础的安全网。试想一个对方法加入额外的参数的重构实例。在静态类型语言中，你可以完成修改，重编译你的系统并容易修改所有引起类型错误的代码行。一旦你完成了这些，你确信已经发现了所有需要修改的地方。对其他的简单重构，如改变方法名或把方法从一个类移到另一个，这种确信都有效。所有例子中静态类型检查会提供足够的确认，表明新系统和旧系统可以一样的工作。  

**文档。**静态类型是被编译器检查过正确性的程序文档。不像普通的注释，类型标注永远都不会过期（至少如果包含它的源文件近期刚刚通过编译就不会）。更进一步说，编译器和集成开发环境可以利用类型标注提供更好的上下文帮助。举例来说，集成开发环境可以通过判定选中表达式的静态类型，找到类型的所有成员，并全部显示出来。  

虽然静态类型对程序文档来说通常很有用，当它们弄乱程序时，也会显得很突兀。标准意义上来说，有用的文档是那些程序的读者不可能很容易地从程序中自己想出来的。在如下的方法定义中：  
`def f(x: String) = ...`  
知道f的变量应该是String是有用的。另一方面，以下例子中两个标注至少有一个多余的：  
`val x: HashMap[Int, String] = new HashMap[Int, String]()`  
很明显，x是以Int为键，String为值的HashMap这句话说一遍就够了；没必要同样的句子重复两遍。

Scala有非常精于此道的类型推断系统，能让你省略几乎所有的通常被认为是不必要的类型信息。在上例中，以下两个替代语句也能进行同样的工作:  
```
val x = new HashMap[Int, String]()
val x: Map[Int, String] = new HashMap()
```
Scala里的类型推断可以走的很远 。实际上，就算用户代码丝毫没有显式类型也不稀奇。因此，Scala编程经常看上去有点像是动态类型脚本语言写出来的程序。尤其显著表现在作为粘接已写完的库控件的客户应用代码上。而对库控件来说不是这么回事，因为它们常常用到相当精妙的类型去使其适于灵活使用的模式。这很自然。综上，构成可重用控件接口的成员的类型符号应该是显式给出的，因为它们构成了控件和它的使用者间契约的重要部分。  

## 14.4 实验步骤
在spark-shell中编写WordCount代码和运行。  

首先我们先编写测试文件in.txt:  
```
hello world
ni hao
hello my friend
ni are my sunshine
```  
上到到HDFS:  
```
root@master:~# vim in.txt
root@master:~# hadoop fs -put in.txt /
root@master:~# hadoop fs -ls /        
Found 2 items
-rw-r--r--   2 root supergroup         54 2018-07-20 02:12 /in.txt
drwx-wx-wx   - root supergroup          0 2018-07-20 02:10 /tmp
```  

启动Spark-shell:  
```
root@master:/usr/local/spark/jars# spark-shell --master spark://master:7077
```

在spark-shell中写入代码:  
```
scala> val file=sc.textFile("hdfs://master:9000/in.txt")
file: org.apache.spark.rdd.RDD[String] = hdfs://master:9000/in.txt MapPartitionsRDD[5] at textFile at <console>:24

scala> val count=file.flatMap(line => line.split(" ")).map(word => (word,1)).reduceByKey(_+_)
count: org.apache.spark.rdd.RDD[(String, Int)] = ShuffledRDD[8] at reduceByKey at <console>:26

scala> count.collect()
res0: Array[(String, Int)] = Array((are,1), (hello,2), (my,2), (friend,1), (hao,1), (world,1), (sunshine,1), (ni,2))
```






