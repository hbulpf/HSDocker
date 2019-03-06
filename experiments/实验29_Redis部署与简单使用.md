# 实验二十九 Redis部署与简单使用

## 29.1 实验目的
1.熟悉了解CentOS系统    
2.学习从C++源代码编译成可执行文件并安装运行  
3.学习安装Redis  
4.学习配置Redis 
5.学会简单使用Redi  

## 29.2 实验要求  
在master节点上，安装配置并简单使用Redis。

## 29.3 实验原理  
### 29.3.1 CentOS简介  
全称为Community Enterprise Operating System（社区企业操作系统），是Linux发行版之一。它是来自于Red Hat Enterprise Linux依照开放源代码规定释出的源代码所编译而成。由于出自同样的源代码，因此有些要求高度稳定性的服务器以CentOS替代商业版的Red Hat Enterprise Linux（RHEL）使用。两者的不同，在于CentOS并不包含封闭源代码软件。最新的CentOS版本是7.2，内核版本是3.10.0。  

### 29.3.2 CentOS与RHEL关系  
CentOS与RHEL的关系：RHEL在发行的时候，有两种方式。一种是二进制的发行方式，另外一种是源代码的发行方式。无论是哪一种发行方式，你都可以免费获得（例如从网上下载），并再次发布。但如果你使用了他们的在线升级（包括补丁）或咨询服务，就必须要付费。RHEL一直都提供源代码的发行方式，CentOS 就是将 RHEL 发行的源代码重新编译一次，形成一个可使用的二进制版本。由于 LINUX 的源代码是GNU，所以从获得 RHEL的源代码到编译成新的二进制，都是合法。只是red hat是商标，所以必须在新的发行版里将red hat的商标去掉。red hat对这种发行版的态度是："我们其实并不反对这种发行版，真正向我们付费的用户，他们重视的并不是系统本身，而是我们所提供的商业服务。"所以，CentOS可以得到RHEL的所有功能，甚至是更好的软件。但CentOS并不向用户提供商业支持，当然也不负上任何商业责任。如果你要将你的 RHEL 转到 CentOS 上，因为你不希望为 RHEL 升级而付费。当然，你必须有丰富linux使用经验，因此RHEL的商业技术支持对你来说并不重要。但如果你是单纯的业务型企业，那么还是建议你选购RHEL软件并购买相应服务。这样可以节省你的IT管理费用，并可得到专业服务。一句话，选用CentOS还是 RHEL，取决于你所在公司是否拥有相应的技术力量。  

### 29.3.3 make简介  
Linux下make 命令是系统管理员和程序员用的最频繁的命令之一。**管理员用它通过命令行来编译和安装很多开源的工具，程序员用它来管理他们大型复杂的项目编译问题**。make命令通常和Makefile一起使用。  

在开发一个系统时，一般是将一个系统分成几个模块，这样做提高了系统的可维护性，但由于各个模块间不可避免存在关联，所以当一个模块改动后，其他模块也许会有所更新，当然对小系统来说，手工编译连接是没问题，但是如果是一个大系统，存在很多个模块，那么手工编译的方法就不适用了。为此，在Linux系统中，专门提供了一个make命令来自动维护目标文件，与手工编译和连接相比，**make命令的优点在于他只更新修改过的文件（在Linux中，一个文件被创建或更新后有一个最后修改时间，make命令就是通过这个最后修改时间来判断此文件是否被修改），而对没修改的文件则置之不理，并且make命令不会漏掉一个需要更新的文件**。  

文件和文件间或模块或模块间有可能存在倚赖关系，make命令也是依据这种依赖关系来进行维护的，所以我们有必要了解什么是依赖关系;make命令当然不会自己知道这些依赖关系，而**需要程序员将这些依赖关系写入一个叫makefile的文件中**。Makefile文件中包含着一些目标，通常目标就是文件名，对每一个目标，提供了实现这个目标的一组命令以及和这个目标有依赖关系的其他目标或文件名，以下是一个简单的Makefile的简单例子：  
```
#一个简单的Makefile
　　prog:prog1.o prog2.o
　　    gcc prog1.o prog2.o -o prog
　　prog1.o:prog1.c lib.h
　　    gcc -c -I. -o prog1.o prog1.c
　　prog2.o:prog2.c
　      gcc -c prog2.c
```  
以上Mamefile中定义了三个目标：prog、prog1和prog2，冒号后是依赖文件列表;  
对于第一个目标文件prog来说，他有两个依赖文件：prog1.o和prog2.o，任何一个依赖文件更新，prog也要随之更新，命令gcc prog1.o prog2.o -o prog是生成prog的命令。**make检查目标是否需要更新时采用递归的方法，递归从底层向上对过时目标进行更新，只有当一个目标所依赖的所有目标都为最新时，这个目标才会被更新**。以上面的Makefile为例，我们修改了prog2.c，执行make时，由于目标prog依赖prog1.o和prog2.o，所以要先检查prog1.o和prog2.o是否过时，目标prog1.o依赖prog1.c和lib.h，由于我们并没修改这两个文件，所以他们都没有过期，接下来再检查目标prog2.o，他依赖prog2.c，由于我们修改了prog2.c，所以prog2.c比目标文件prog2.o要新，即prog2.o过期，而导致了依赖prog2.o的所有目标都过时;这样make会先更新prog2.o再更新prog。  

### 29.3.4 Redis简介  
**redis是一个开源的使用ANSI C语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API**。从2010年3月15日起，Redis的开发工作由VMware主持。从2013年5月开始，Redis的开发由Pivotal赞助。  

redis是一个key-value存储系统。和Memcached类似，它支持存储的value类型相对更多，包括string(字符串)、list(链表)、set(集合)、zset(sorted set --有序集合)和hash（哈希类型）。这些数据类型都支持push/pop、add/remove及取交集并集和差集及更丰富的操作，而且这些操作都是原子性的。在此基础上，redis支持各种不同方式的排序。**与memcached一样，为了保证效率，数据都是缓存在内存中。区别的是redis会周期性的把更新的数据写入磁盘或者把修改操作写入追加的记录文件，并且在此基础上实现了master-slave(主从)同步**。  

Redis 是一个高性能的key-value数据库。 redis的出现，很大程度补偿了memcached这类key/value存储的不足，在部分场合可以对关系数据库起到很好的补充作用。它提供了Java，C/C++，C#，PHP，JavaScript，Perl，Object-C，Python，Ruby，Erlang等客户端，使用很方便。  
Redis支持主从同步。数据可以从主服务器向任意数量的从服务器上同步，从服务器可以是关联其他从服务器的主服务器。这使得Redis可执行单层树复制。存盘可以有意无意的对数据进行写操作。由于完全实现了发布/订阅机制，使得从数据库在任何地方同步树时，可订阅一个频道并接收主服务器完整的消息发布记录。同步对读取操作的可扩展性和数据冗余很有帮助。  

## 29.4 实验步骤  
本实验包括安装、配置与使用三部分，下面按此三部分依次讲述。  

### 29.4.1 安装配置启动  
这次的安装选用spark集群(实验30有用到hadoop和spark), 安装之前先安装gcc和make:  
```
sudo apt-get update
sudo apt-get install gcc
sudo apt-get install make
```  

安装完后从官网下载Redis安装包,[下载链接](https://redis.io/download)  

这里下载的是最新的4.0.11版本，下载后解压至/usr/local/redis目录:  
```
root@master:~# tar -zxvf redis-4.0.11.tar.gz
root@master:~# mv redis-4.0.11 /usr/local/redis
```  

进入/usr/local/redis目录，执行make命令进行编译:  
```
root@master:/usr/local/redis# make  
root@master:/usr/local/redis# make install
```
(输出会有很多，已省略)  

接着编辑/usr/local/redis/redis.conf文件,  
找到`bind 127.0.0.1`  将其改为本机ip`bind 172.19.0.2` (172.19.0.2是我的master节点的ip)  

最后，使用“redis-server”命令**（启动脚本在src目录下），指定上述配置文件，启动Redis:  
```
root@master:/usr/local/redis/src# ./redis-server /usr/local/redis/redis.conf &
[1] 3818
root@master:/usr/local/redis/src# 3818:C 09 Aug 01:02:11.236 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
3818:C 09 Aug 01:02:11.236 # Redis version=4.0.11, bits=64, commit=00000000, modified=0, pid=3818, just started
3818:C 09 Aug 01:02:11.236 # Configuration loaded
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 4.0.11 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 3818
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

3818:M 09 Aug 01:02:11.239 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
3818:M 09 Aug 01:02:11.239 # Server initialized
3818:M 09 Aug 01:02:11.239 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
3818:M 09 Aug 01:02:11.239 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
3818:M 09 Aug 01:02:11.239 * Ready to accept connections

```  

### 29.4.2 使用Redis  
向redis里写入数据:  
```
root@master:/usr/local/redis/src# ./redis-cli -h 172.19.0.2
172.19.0.2:6379> set chengshi sh,bj,sz,nj,hf
OK
172.19.0.2:6379> get chengshi
"sh,bj,sz,nj,hf"
```

