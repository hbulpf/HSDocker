
# HSDocker : Hadoop Spark On Docker 

[![知识共享协议（CC协议）](https://img.shields.io/badge/License-Creative%20Commons-DC3D24.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh)
[![GitHub stars](https://img.shields.io/github/stars/hbulpf/HSDocker.svg?label=Stars)](https://github.com/hbulpf/HSDocker)
[![GitHub watchers](https://img.shields.io/github/watchers/hbulpf/HSDocker.svg?label=Watchers)](https://github.com/hbulpf/HSDocker/watchers)
[![GitHub forks](https://img.shields.io/github/forks/hbulpf/HSDocker.svg?label=Forks)](https://github.com/hbulpf/HSDocker/fork)

基于容器面向大数据与人工智能的数据平台。其核心功能为：

- 基于Kubernetes的容器编排与与监控系统
- 将hadoop和spark等大数据平台封装为容器集群并在kubernetes上运行
- 将诸多机器学习/深度学习平台封装为容器集群并在kubernetes上运行

## 一、[Hadoop Or AI on Kubernetes](./k8s_apps/README.md)
### [Hadoop on Kubernetes]()
1. [Hadoop集群 部署到 Kubernetes](./k8s_apps/hadoop_on_k8s/)
1. [Spark集群 部署到 Kubernetes](./k8s_apps/spark_on_k8s/)
1. [HBase 集群 部署到 Kubernetes](./k8s_apps/hbase_on_k8s/)
1. [Hive 集群 部署到 Kubernetes](./k8s_apps/hive_on_k8s/)
1. [Storm 集群 部署到 Kubernetes](./k8s_apps/storm_on_k8s/)
1. [Kafka 集群 部署到 Kubernetes](./k8s_apps/kafka_on_k8s/)
1. [Pig 集群 部署到 Kubernetes](./k8s_apps/pig_on_k8s/)
1. [Flume 集群 部署到 Kubernetes](./k8s_apps/flume_on_k8s/)

### ML/DL on Kubernetes
1. [Tensorflow 1.12](./k8s_apps/tf1.12.0_on_k8s/)
1. [车牌识别实验](./k8s_apps/plate-dection/)

## 二、[系统实验](./experiments/README.md)

1. [大数据平台实验](./experiments/README.md)

2. CI/CD实验
    1. [HelloWorld:使用springboot构建docker容器第一个demo](./springboot_docker/docker-spring-boot)


## 三、[大数据组件容器制作](https://github.com/hbulpf/bigdata_on_docker)
1. [使用Hadoop-2.7.2在Docker中部署Hadoop集群](./hadoopspark/demo_1-HadoopClusterRaw)
2. [基于Docker搭建定制版Hadoop集群](./hadoopspark/demo_2-docker-cluster)

## 四、 其他研究
### 1. 容器云相关企业
<table>
<tr> 
<td> 容器云厂商 </td><td> <a href='http://www.alauda.cn/product/detail/id/68.html'>灵雀云</a></td>
<td> <a href='https://www.qiniu.com/products/kirk'>七牛云</a></td>
<td> <a href='https://www.shurenyun.com/scene-bigdata.html'>数人云</a></td>
<td> <a href='https://www.qingcloud.com'>青云</a></td>
<td> <a href='https://caicloud.io/'>才云</a></td>
</tr>
<tr><td> 容器云教育 </td>
<td><a href='http://www.cstor.cn/'>云创大数据</a></td>
<td><a href='https://www.aliyun.com/solution/eductione1000?from=timeline&isappinstalled=0'>阿里云</a></td>
</tr>
</table>

### 2. 开源项目

+   **[Kubernetes](https://https://github.com/kubernetes/kubernetes)**
    - 说明: Kubernetes官方开源项目

+   **[Big Data Europe](https://www.big-data-europe.eu/)**  
    - github: [https://github.com/big-data-europe](https://github.com/big-data-europe)  
	- 说明: Integrating Big Data, software & communicaties for addressing Europe's societal challenges
   
+   **[SequenceIQ](http://www.sequenceiq.com/)**
    *  github: https://github.com/sequenceiq

+ 	**[kubeflow](https://github.com/kubeflow/kubeflow)** 
	- 说明: 机器学习/深度学习平台的容器化

+ **[XLearning](https://github.com/Qihoo360/XLearning/blob/master/README_CN.md)**
    - 说明: 一款支持多种机器学习、深度学习框架的调度系统。基于Hadoop Yarn完成了对TensorFlow、MXNet、Caffe、Theano、PyTorch、Keras、XGBoost等常用框架的集成，同时具备良好的扩展性和兼容性。

+ **[horovod](https://github.com/horovod/horovod)**
    - 说明: Distributed training framework for TensorFlow, Keras, PyTorch, and Apache MXNet.
    
+ **[volcano](https://github.com/volcano-sh/volcano)**
   - 说明:  a batch system built on Kubernetes

### 五、实验系统访问
- Kubernetes DashBoard : [内网访问](https://50126.hnbdata.cn:8343)  [外网访问](https://frp.hnbdata.cn:26343)
- Kubernetes集群与应用监控 : [内网访问](http://50126.hnbdata.cn:8081)  [外网访问](http://frp.hnbdata.cn:26381)  管理员/密码: admin/admin

----------------------------------------

**项目规范**

本文使用 [`Markdown`](https://www.markdownguide.org/basic-syntax) 编写, 排版符合[`中文技术文档写作规范`](https://github.com/hbulpf/document-style-guide)。Find Me On [**Github**](https://github.com/hbulpf/HSDocker) , [**Gitee**](https://gitee.com/sifangcloud/HSDocker)

**友情贡献**

@[**chellyk**](https://github.com/chellyk)  &nbsp;  @[**RunAtWorld**](http://www.github.com/RunAtWorld)   &nbsp;  @[**icepoint666**](https://www.github.com/icepoint666) 
