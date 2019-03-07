# 实验1——基本操作实验

## 1.1 实验目的
1． 熟悉Linux基本命令;  
2． 掌握Java基本命令；
3． 掌握vi编辑器的使用；

## 1.2 实验要求
1． 通过vi编辑器编写Java程序；
2． 通过Java命令编译和运行编写的Java程序；
3． 通过Jar命令打包编写的Java程序；

## 1.3 实验原理
### 1.3.1 Linux基本命令

Linux是一套免费使用和自由传播的类Unix操作系统，是一个基于POSIX和UNIX的多用户、多任务、支持多线程和多CPU的操作系统。它能运行主要的UNIX工具软件、应用程序和网络协议。它支持32位和64位硬件。Linux继承了Unix以网络为核心的设计思想，是一个性能稳定的多用户网络操作系统。  

Linux操作系统诞生于1991年10月5日。Linux存在着许多不同的Linux版本，但它们都使用了Linux内核。Linux可安装在各种计算机硬件设备中，比如手机、平板电脑、路由器、视频游戏控制台、台式计算机、大型机和超级计算机。
严格来讲，Linux这个词本身只表示Linux内核，但实际上人们已经习惯了用Linux来形容整个基于Linux内核，并且使用GNU工程各种工具和数据库的操作系统。  
  
本小节将介绍实验中涉及到的Linux操作系统命令：
(1)查看当前目录
pwd命令用于显示当前目录：
```
[root@master ~]# pwd
/root
```
(2)目录切换
cd命令用来切换目录：
```
[root@master ~]# cd  /usr/cstor
[root@master cstor]# pwd
/usr/cstor
[root@master cstor]#
```
(3)文件罗列
ls命令用于查看文件与目录：
``[root@master cstor]# ls``
(4)文件或目录拷贝
cp命令用于拷贝文件，若拷贝的对象为目录，则需要使用-r参数：
``[root@master cstor]#  cp  -r hadoop  /root/hadoop``
(5)文件或目录移动或重命名
mv命令用于移动文件，在实际使用中，也常用于重命名文件或目录：
``[root@master ~]#  mv  hadoop  hadoop2 ``                       #当前位于/root，不是/usr/cstor
(6)文件或目录删除
rm命令用于删除文件，若删除的对象为目录，则需要使用-r参数：
``[root@master ~]#  rm  -rf  hadoop2``                            #当前位于/root，不是/usr/cstor
(7)进程查看
ps命令用于查看系统的所有进程：
``[root@master ~]# ps``                                           # 查看当前进程
(8)文件压缩与解压
tar命令用于文件压缩与解压，参数中的c表示压缩，x表示解压缩：
```
[root@master ~]# tar -zcvf  /root/hadoop.tar.gz  /usr/cstor/hadoop
[root@master ~]# tar -zxvf  /root/hadoop.tar.gz
```
(9)查看文件内容
cat命令用于查看文件内容：
``[root@master ~]# cat  /usr/cstor/hadoop/etc/hadoop/core-site.xml``
(10)查看服务器IP配置
ip addr命令用于查看服务器IP配置：
```
[root@master ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
125: eth0@if126: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:ac:11:00:0c brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.12/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:c/64 scope link
       valid_lft forever preferred_lft forever
[root@master ~]#
```

### 1.3.2 Vi编辑器
vi编辑器通常被简称为vi，而vi又是visual editor的简称。它在Linux上的地位就像Edit程序在DOS上一样。它可以执行输出、删除、查找、替换、块操作等众多文本操作，而且用户可以根据自己的需要对其进行定制，这是其他编辑程序所没有的。  

vi 编辑器并不是一个排版程序，它不像Word或WPS那样可以对字体、格式、段落等其他属性进行编排，它只是一个文本编辑程序。没有菜单，只有命令，且命令繁多。vi有3种基本工作模式：**命令行模式、文本输入模式和末行模式**。
Vim是vi的加强版，比vi更容易使用。vi的命令几乎全部都可以在vim上使用。  

vi编辑器是Linux和Unix上广泛使用的文本编辑器，工作在字符模式下。由于不需要图形界面，vi是效率很高的文本编辑器。尽管在Linux上也有很多图形界面的编辑器可用，但vi在系统和服务器管理中的功能是那些图形编辑器所无法比拟的。
Vi或vim是实验中用常用的文件编辑命令，命令行嵌入“vi/vim 文件名”后，默认进入“命令模式”，不可编辑文档，需键盘点击**“i”**键，方可编辑文档，编辑结束后，需按**“ESC”**键，先退回命令模式，再按**“：”**进入末行模式，接着嵌入**“wq”**方可保存退出。下述的图1-6为vi/vim三种模式转换示意图，图1-7为vi/vim操作实例。

图1-6
![图1-6](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex1/image/1.png)

图1-7
![图1-7](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex1/image/2.png)

### 1.3.3 Java基本命令
在安装Java环境后，可以使用Java命令来编译、运行或者打包Java程序。
(1)查看Java版本
```
[root@client ~]# java -version
java version "1.7.0_79"
Java(TM) SE Runtime Environment (build 1.7.0_79-b15)
Java HotSpot(TM) 64-Bit Server VM (build 24.79-b02, mixed mode)
```
(2)编译Java程序
``[root@client ~]# javac Helloworld.java``
(3)运行Java程序
```
[root@client ~]# java Helloworld
Hello World!
```
(4)打包Java程序
```
[root@client ~]# jar -cvf Helloworld.jar Helloworld.class
added manifest
adding: Helloworld.class(in = 426) (out= 289)(deflated 32%)
```
由于打包时并没有指定manifest文件，因此该jar包无法直接运行：
```
[root@client ~]# java -jar Helloworld.jar
no main manifest attribute, in Helloworld.jar
```
(5)打包携带manifest文件的Java程序
manifest文件用于描述整个Java项目，常用功能是指定项目的入口类：
```
[root@client ~]# cat manifest.mf
Main-Class: Helloworld
```
打包时，加入-m参数，并指定manifest文件名：
```
[root@client ~]# jar -cvfm Helloworld.jar manifest.mf Helloworld.class
added manifest
adding: Helloworld.class(in = 426) (out= 289)(deflated 32%)
```
之后，即可使用java命令直接运行该jar包：
```
[root@client ~]# java -jar Helloworld.jar
Hello World!
```


  [1]: https://github.com/chellyk/Bigdata-experiment/blob/master/ex1/image/1.png