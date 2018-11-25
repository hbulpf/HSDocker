# Kubeflow文档

> Kubeflow，顾名思义，是Kubernetes + Tensorflow，是Google为了支持自家的Tensorflow的部署而开发出的开源平台，当然它同时也支持Pytorch和基于Python的SKlearn等其它机器学习的引擎。

> KubeFlow支持实现从JupyterHub模型开发，TFJob模型训练到TF-serving，Seldon预测端到端的解决方案。

> KubeFlow需要用户精通Kubernetes，比如写一个TFJob的部署yaml文件。

Kukeflow主要提供在生产系统中简单的大规模部署机器学习的模型的功能，利用Kubernetes，它可以做到：
- 简单，可重复，可移植的部署
- 利用微服务提供松耦合的部署和管理
- 按需扩大规模

### 1.背景

Kubernetes 本来是一个用来管理无状态应用的容器平台，但是在近两年，有越来越多的公司用它来运行各种各样的工作负载，尤其是机器学习炼丹。各种 AI 公司或者互联网公司的 AI 部门都会尝试在 Kubernetes 上运行 TensorFlow，Caffe，MXNet 等等分布式学习的任务，这为 Kubernetes 带来了新的挑战。

首先，分布式的机器学习任务一般会涉及参数服务器（以下称为 PS）和工作节点（以下成为 worker）两种不同的工作类型。而且不同领域的学习任务对 PS 和 worker 有不同的需求，这体现在 Kubernetes 中就是配置难的问题。以 TensorFlow 为例，TensorFlow 的分布式学习任务通常会启动多个 PS 和多个 worker，而且在 TensorFlow 提供的最佳实践中，每个 worker 和 PS 要求传入不同的命令行参数。举例说明：
```shell
    # On ps0.example.com:
    $ python trainer.py \
         --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
         --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
         --job_name=ps --task_index=0
    # On ps1.example.com:
    $ python trainer.py \
         --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
         --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
         --job_name=ps --task_index=1
    # On worker0.example.com:
    $ python trainer.py \
         --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
         --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
         --job_name=worker --task_index=0
    # On worker1.example.com:
    $ python trainer.py \
         --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
         --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
         --job_name=worker --task_index=1
    
```
其中需要的参数有四个，一个是所有的 PS 的网络地址（主机名-端口），以及所有的 worker 的网络地址。另外是 job 的类型，分为 PS 与 worker 两种。最后是任务的 index，从 0 开始递增。因此在此例中，用户需要写至少四个 pod 的配置文件，以及四个 service 的配置文件，使得 PS 跟 worker 可以互相访问，况且这只是一个机器学习任务。如果大规模地在 Kubernetes 上运行 TensorFlow 分布式任务，可以预见繁杂的配置将成为机器学习工程师们新的负担。

其次，Kubernetes 默认的调度器对于机器学习任务的调度并不友好。如果说之前的问题只是在应用与部署阶段比较麻烦，那调度引发的资源利用率低，或者机器学习任务效率下降的问题，就格外值得关注。机器学习任务对于计算和网络的要求相对较高，一般而言所有的 worker 都会使用 GPU 进行训练，而且为了能够得到一个较好的网络支持，尽可能地同一个机器学习任务的 PS 和 worker 放在同一台机器或者网络较好的相邻机器上会降低训练所需的时间。

### 2. 基本原理

针对这些问题，Kubeflow 项目应运而生，它以 TensorFlow 作为第一个支持的框架，在 Kubernetes 上定义了一个新的资源类型：TFJob，即 TensorFlow Job 的缩写。通过这样一个资源类型，使用 TensorFlow 进行机器学习训练的工程师们不再需要编写繁杂的配置，只需要按照他们对业务的理解，确定 PS 与 worker 的个数以及数据与日志的输入输出，就可以进行一次训练任务。

Kubeflow基于K8s的微服务架构，其核心组件包括：
- Jupyterhub  多租户Nootbook服务
- Tensorflow/Pytorch/MPI/MXnet/Chainer  主要的机器学习引擎
- Seldon 提供在K8s上对于机器学习模型的部署
- Argo 基于K8s的工作流引擎
- Ambassador  API Gateway
- Istio 提供微服务的管理，Telemetry收集
- Ksonnet  K8s部署工具

**实现介绍：**

Kubeflow 以 TensorFlow 作为第一个支持的框架，为其实现了一个在 Kubernetes 上的 operator：tensorflow/k8s。由于在 Kubernetes 上内置的资源类型，如 deployment，replicaset，或者是 pod 等，都很难能够简练而清晰地描述一个分布式机器学习的任务，因此我们利用 Kubernetes 的 Custom Resource Definition 特性，定义了一个新的资源类型：TFJob，即 TensorFlow Job 的缩写。一个 TFJob 配置示例如下所示：
```yaml
    apiVersion: "kubeflow.org/v1alpha1"
    kind: "TFJob"
    metadata:
      name: "example-job"
    spec:
      replicaSpecs:
        - replicas: 1
          tfReplicaType: MASTER
          template:
            spec:
              containers:
                - image: gcr.io/tf-on-k8s-dogfood/tf_sample:dc944ff
                  name: tensorflow
              restartPolicy: OnFailure
        - replicas: 1
          tfReplicaType: WORKER
          template:
            spec:
              containers:
                - image: gcr.io/tf-on-k8s-dogfood/tf_sample:dc944ff
                  name: tensorflow
              restartPolicy: OnFailure
        - replicas: 2
          tfReplicaType: PS
          template:
            spec:
              containers:
                - image: gcr.io/tf-on-k8s-dogfood/tf_sample:dc944ff
                  name: tensorflow
              restartPolicy: OnFailure
    
```
实现：任何一个 PS 或者 worker，都由两个资源组成，分别是 job 和 service。其中 job 负责创建出 PS 或者 worker 的 pod，而 service 负责将其暴露出来。这里社区目前也在重新考虑选型，目前希望可以直接创建 pod 而非 job，而用 headless service 替代 service，因为 PS worker 不需要暴露给除了该分布式学习任务外的其他服务。

### 3.应用场景

虽说Tensorflow是自家的机器学习引擎，但是Google的Kubeflow也提供了对其它不同引擎的支持，包含：

- Pytorch  PyTorch是由Facebook的人工智能研究小组开发，基于Torch的开源Python机器学习库。
- MXnet Apache MXNet是一个现代化的开源深度学习软件框架，用于训练和部署深度神经网络。它具有可扩展性，允许快速模型培训，并支持灵活的编程模型和多种编程语言 MXNet库是可移植的，可以扩展到多个GPU和多台机器。
- Chainer  Chainer是一个开源深度学习框架，纯粹用Python编写，基于Numpy和CuPy Python库。 该项目由日本风险投资公司Preferred Networks与IBM，英特尔，微软和Nvidia合作开发。 Chainer因其早期采用“按运行定义”方案以及其在大规模系统上的性能而闻名。Kubeflow对Chainer的支持要到下一个版本。现在还在Beta。
- MPI  使用MPI来训练Tensorflow。这部分看到的资料比较少。

这些都是用Kubernetes CDRs的形式来支持的，用户只要利用KS创建对应的组件来管理就好了。

### 4.部署

Requirements:

- ksonnet version 0.11.0 or later.
- Kubernetes 1.8 or later
- kubectl

当前kubeflow tag:  v0.3.3

需要有一个正在运行的 Kubernetes 集群，而且集群的版本要大于等于 1.8。

以下两种方式可以创建一个单节点的本地 Kubernetes 集群：

使用 Kubernetes 里的 local-up-cluster.sh 脚本

使用 minikube 项目

其中前者会在本地创建一个 native 的 Kubernetes 集群，

而后者则会在本地的虚拟机里创建出 Kubernetes 集群。

如果你已经成功地创建了一个 Kubernetes 集群，那么接下来就是在这一集群上创建 Kubeflow 所有的组件，这一步需要用到 ksonnet，一个简化应用在 Kubernetes 上的分发与部署的命令行工具，它会帮助你创建 Kubeflow 所需组件。在安装了 ksonnet 后，接下来只需要运行下面的命令，就可以完成 Kubeflow 的部署。
```shell
    # Initialize a ksonnet APP
    APP_NAME=my-kubeflow
    ks init ${APP_NAME}
    cd ${APP_NAME}
    
    # Install Kubeflow components
    ks registry add kubeflow github.com/kubeflow/kubeflow/tree/master/kubeflow
    ks pkg install kubeflow/core
    ks pkg install kubeflow/tf-serving
    ks pkg install kubeflow/tf-job
    
    # Deploy Kubeflow
    NAMESPACE=default
    kubectl create namespace ${NAMESPACE}
    ks generate core kubeflow-core --name=kubeflow-core --namespace=${NAMESPACE}
    ks apply default -c kubeflow-core
    
```
### 5.Demo

下面的yaml配置是Kubeflow提供的一个CNN Benchmarks的例子：
```yaml
    apiVersion: kubeflow.org/v1alpha2
    kind: TFJob
    metadata:
      labels:
        ksonnet.io/component: mycnnjob
      name: mycnnjob
      namespace: kubeflow
    spec:
      tfReplicaSpecs:
        Ps:
          template:
            spec:
              containers:
              - args:
                - python
                - tf_cnn_benchmarks.py
                - --batch_size=32
                - --model=resnet50
                - --variable_update=parameter_server
                - --flush_stdout=true
                - --num_gpus=1
                - --local_parameter_device=cpu
                - --device=cpu
                - --data_format=NHWC
                image: gcr.io/kubeflow/tf-benchmarks-cpu:v20171202-bdab599-dirty-284af3
                name: tensorflow
                workingDir: /opt/tf-benchmarks/scripts/tf_cnn_benchmarks
              restartPolicy: OnFailure
          tfReplicaType: PS
        Worker:
          replicas: 1
          template:
            spec:
              containers:
              - args:
                - python
                - tf_cnn_benchmarks.py
                - --batch_size=32
                - --model=resnet50
                - --variable_update=parameter_server
                - --flush_stdout=true
                - --num_gpus=1
                - --local_parameter_device=cpu
                - --device=cpu
                - --data_format=NHWC
                image: gcr.io/kubeflow/tf-benchmarks-cpu:v20171202-bdab599-dirty-284af3
                name: tensorflow
                workingDir: /opt/tf-benchmarks/scripts/tf_cnn_benchmarks
              restartPolicy: OnFailure             
```
在Kubeflow中运行这个例子，会创建一个TFjob。可以使用Kubectl来管理，监控这个Job的运行。
```shell
    # 监控当前状态
    kubectl get -o yaml tfjobs <jobname> -n <ns>
    
    # 查看事件
    kubectl describe tfjobs <jobname> -n <ns>
    
    # 查看运行日志
    kubectl logs mycnnjob-[ps|worker]-0 -n <ns>
```
参考链接：

1. Kubeflow 安利：在 Kubernetes 上进行机器学习
   https://zhuanlan.zhihu.com/p/3358363
2. 轻松扩展你的机器学习能力 ： Kubeflow
   https://my.oschina.net/taogang/blog/2052152
3. Get started with kubeflow
   https://www.kubeflow.org/docs/started/getting-started/
