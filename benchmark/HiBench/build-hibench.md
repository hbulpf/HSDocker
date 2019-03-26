### 全部构建 ###
要在HiBench中简单构建所有模块，请使用以下命令。这可能非常耗时，因为hadoopbench依赖于Mahout和Nutch等第三方工具。构建过程会自动为您下载这些工具。如果您不运行这些工作负载，则只能构建特定框架以加快构建过程。

    mvn -Dspark=2.1 -Dscala=2.11 clean package


### 构建特定的框架基准 ###
HiBench 6.0支持仅为特定框架构建基准。例如，要仅构建Hadoop基准测试，我们可以使用以下命令：（注意spark和scale的版本）

    mvn -Phadoopbench -Dspark=2.2 -Dscala=2.11 clean package

构建Hadoop和Spark基准测试

    mvn -Phadoopbench -Psparkbench -Dspark=2.2 -Dscala=2.11 clean package

支持的框架包括：hadoopbench，sparkbench，flinkbench，stormbench，gearpumpbench。

### 指定Scala版本 ###
要指定Scala版本，请使用-Dscala = xxx（2.10或2.11）。默认情况下，它为scala 2.11构建。

    mvn -Dscala=2.11 clean package
提示：因为一些Maven插件不能完美支持Scala版本，所以有一些例外。

1. 无论指定什么Scala版本，模块（gearpumpbench / streaming）总是在Scala 2.11中构建。
2. 当spark版本指定为2.0时，模块（sparkbench / streaming）仅支持Scala 2.11。



### 指定Spark版本 ###
要指定spark版本，请使用-Dspark = xxx（1.6,2.0,2.1或2.2）。默认情况下，它为spark 2.0构建

    mvn -Psparkbench -Dspark=2.2 -Dscala=2.11 clean package
提示：当spark版本指定为spark2.0（1.6）时，默认情况下scala版本将指定为scala2.11（2.10）。例如，如果我们想使用spark2.0和scala2.11来构建hibench。我们只是使用命令 `mvn -Dspark=2.0 clean
package` ，但对于spark2.0和scala2.10，我们需要使用该命令 `mvn -Dspark=2.0 -Dscala=2.10 clean package` 。同样，spark1.6默认与scala2.10相关联。

### 构建单个模块 ###
如果您只对HiBench中的单个工作负载感兴趣。您可以构建单个模块。例如，以下命令仅构建Spark的SQL工作负载。

    mvn -Psparkbench -Dmodules -Psql -Dspark=2.1 -Dscala=2.11 clean package

支持的模块包括：micro，ml（机器学习），sql，websearch，graph，streaming，structuredStreaming（spark 2.0或2.1）。

### 构建结构化流媒体 ###
对于Spark 2.0和Spark 2.1，我们添加了对结构化流的基准支持。这是一个无法在Spark 1.6中编译的新模块。即使您将spark版本指定为2.0或2.1，它也不会默认编译。您必须明确指定它：

    mvn -Psparkbench -Dmodules -PstructuredStreaming clean package 
