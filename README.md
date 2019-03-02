# 容器化 Hadoop Spark 实战 #
## 一、整体思路 ##
1. 研究Springboot部署微服务的过程；研究Kubernetes（简称K8S）,Mesos调度容器的过程。最终实现基于Springboot,Docker,K8S,Mesos等开源工具快速搭建一套微服务架构的容器群。
2. 研发基于daocloud等开源工具建立支持容器的可视化管理和监控的系统。
3. 熟悉Hadoop，Spark集群的搭建过程，并抽取关键的配置参数作为大数据平台容器的启动参数。
4. 实现基于容器的自定义大数据平台管理与监控系统。其核心功能为：
	- 基本的容器监控与管理系统：
        - Kubernetes DashBoard : [内网访问](https://50126.hnbdata.cn:8343)  [外网访问](https://frp.hnbdata.cn:26343)
        - Kubernetes集群与应用监控 : [内网访问](http://50126.hnbdata.cn:8081)  [外网访问](http://frp.hnbdata.cn:26381) 管理员/密码: admin/admin
	- 支持半自动化的大数据集群搭建,
	- 封装hadoop和spark大数据平台组件并能组装为大数据集群
	- 大数据集群的较强的动态伸缩能力



## 二、大数据实验
### 1. springboot与docker
1. [HelloWorld:使用springboot构建docker容器第一个demo](./springboot_docker/docker-spring-boot)

### 2. [大数据组件系列实验](./experiments/README.md)

### 3. 容器化大数据组件
1. [使用Hadoop-2.7.2在Docker中部署Hadoop集群](./hadoopspark/demo_1-HadoopClusterRaw)
2. [基于Docker搭建定制版Hadoop集群](./hadoopspark/demo_2-docker-cluster)


### 4. Hadoop on Kubernetes
1. [ Hadoop集群 部署到 Kubernetes 上](./k8s_apps/hadoop_on_k8s/)
1. [ Spark集群 部署到 Kubernetes 上](./k8s_apps/spark_on_k8s/)

## 四、 深度学习
### 1. 基本实验
### 2. 容器化深度学习

## 五、 其他
### 1. 容器云相关企业
<table>
<tr> 
<td> 容器云厂商 </td><td> <a href='http://www.alauda.cn/product/detail/id/68.html'>灵雀云</a></td>
<td> <a href='https://www.qiniu.com/products/kirk'>七牛云</td>
<td> <a href='https://www.shurenyun.com/scene-bigdata.html'>数人云</td>
<td> <a href='https://www.qingcloud.com'>青云</td>
</tr>
<tr><td> 容器云教育 </td><td><a href='http://www.cstor.cn/'>云创大数据</td></td></tr>
</table>

### 2. 开源项目
+   **[Big Data Europe](https://www.big-data-europe.eu/)**  
    - github: [https://github.com/big-data-europe](https://github.com/big-data-europe)  
	- 说明: Integrating Big Data, software & communicaties for addressing Europe's societal challenges
+   **[kubernetes](https://https://github.com/kubernetes/kubernetes)**

+ 	**[kubeflow](https://github.com/kubeflow/kubeflow)** 
	- 说明: 机器学习/深度学习平台的容器化


## 贡献者

@[**chellyk**](https://github.com/chellyk) @[**RunAtWorld**](http://www.github.com/RunAtWorld) @[**icepoint666**](https://www.github.com/icepoint666) 
GitHub : [https://github.com/hbulpf/HSDocker](https://github.com/hbulpf/HSDocker)

