### 1. 设置###

 * Python 2.x（> = 2.6）是必需的。

 * `bc` 需要生成HiBench报告。

 * 支持的Hadoop版本：Apache Hadoop 2.x，CDH5.x，HDP

 * 支持的Spark版本：1.6.x，2.0.x，2.1.x，2.2.x

 * 根据[构建HiBench](build-hibench.md)构建HiBench。

 * 在群集中启动HDFS，Yarn，Spark。


### 2. 配置  `hadoop.conf` ###

创建和编辑 `conf/hadoop.conf`：

    cp conf/hadoop.conf.template conf/hadoop.conf

正确设置以下属性：

属性       |      属性
----------------|--------------------------------------------------------
hibench.hadoop.home     |      Hadoop的安装位置
hibench.hadoop.executable  |   hadoop可执行文件的路径。对于Apache Hadoop，它是/ YOUR / HADOOP / HOME / bin / hadoop
hibench.hadoop.configure.dir | Hadoop配置目录。对于Apache Hadoop，它是/ YOUR / HADOOP / HOME / etc / hadoop
hibench.hdfs.master       |    存储HiBench数据的根HDFS路径，即hdfs：// localhost：8020 / user / username
hibench.hadoop.release    |    Hadoop发布提供商。支持的值：apache，cdh5，hdp

注意：对于鼎晖和HDP用户，请更新hibench.hadoop.executable，hibench.hadoop.configure.dir并hibench.hadoop.release正常。默认值是Apache版本。

`hadoop.conf`内容如下：

    # Hadoop home
    hibench.hadoop.home  /usr/local/hadoop/hadoop-2.7.7

    # The path of hadoop executable
    hibench.hadoop.executable     ${hibench.hadoop.home}/bin/hadoop

    # Hadoop configraution directory
    hibench.hadoop.configure.dir  ${hibench.hadoop.home}/etc/hadoop

    # The root HDFS path to store HiBench data
    hibench.hdfs.master   hdfs://pxw501-25:9000

    # Hadoop release provider. Supported value: apache, cdh5, hdp
    hibench.hadoop.release    apache


### 3. 运行工作负载 ###

3.1 运行单个工作负载即 `wordcount`.

    chmod a+x -R Hibench
    bin/workloads/micro/wordcount/prepare/prepare.sh
    bin/workloads/micro/wordcount/hadoop/run.sh

在 `prepare.sh` 启动一个Hadoop作业生成HDFS上的输入数据。在 `run.sh` 提交一个Hadoop作业的集群。
`bin/run_all.sh`可用于运行conf / benchmarks.lst和conf / frameworks.lst中列出的所有工作负载。

3.2 运行-+

### 4. 查看报告 ###

   它 `<HiBench_Root>/report/hibench.report` 是汇总的工作负载报告，包括工作负载名称，执行持续时间，数据大小，每个群集的吞吐量，每个节点的吞吐量

   报告目录还包含有关调试和调整的更多信息。

  * `<workload>/hadoop/bench.log`: 客户端的原始日志。
  * `<workload>/hadoop/monitor.html`: 系统利用率监视结果。
  * `<workload>/hadoop/conf/<workload>.conf`: 为此工作负载生成的环境变量配置。 

### 5. 输入数据大小 ###

  要改变输入数据的大小，可以设置 `hibench.scale.profile` 在 `conf/hibench.conf`. 可用值很小，小，大，巨大，巨大和大数据。这些配置文件的定义可以在工作负载的conf文件中找到，即 `conf/workloads/micro/wordcount.conf`

### 6. 调整 ###

更改以下属性 `conf/hibench.conf` 以控制并行度。

属性        |      含义
----------------|--------------------------------------------------------
hibench.default.map.parallelism     |    hadoop中的映射器编号
hibench.default.shuffle.parallelism  |   hadoop中的减速器编号

