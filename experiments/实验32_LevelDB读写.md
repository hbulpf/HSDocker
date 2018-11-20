# 实验三十二 LevelDB实验：读写LevelDB

## 32.1 实验目的  
1.了解LevelDB的使用场景；  
2.理解LevelDB数据存储结构；  
3.比较LevelDB和redis的区别；  
4.能对LevelDB的整体架构有一定的了解；  
5.能正确的使用LevelDB并能进行简单使用。  

## 32.2 实验要求  
本实验要求同学能够使用C++语言完成对LevelDB库完成以下操作：  
1.连接到LevelDB数据库；  
2.写入数据；  
3.读取数据；  
4.删除数据。  

## 32.3 实验原理  
**LevelDB是Google开源的持久化KV单机数据库，具有很高的随机写，顺序读/写性能**，但是随机读的性能很一般，也就是说，**LevelDB很适合应用在查询较少，而写很多的场景**。LevelDB应用了LSM (Log Structured Merge)策略，lsm_tree对索引变更进行延迟及批量处理，并通过一种类似于归并排序的方式高效地将更新迁移到磁盘，降低索引插入开销。  

特点:  
1.key和value都是任意长度的字节数组；  
2.entry（即一条K-V记录）默认是按照key的字典顺序存储的，当然开发者也可以重载这个排序函数；  
3.提供的基本操作接口：Put()、Delete()、Get()、Batch()；  
4.支持批量操作以原子操作进行；  
5.可以创建数据全景的snapshot(快照)，并允许在快照中查找数据；  
6.可以通过前向（或后向）迭代器遍历数据（迭代器会隐含的创建一个snapshot）；  
7.自动使用Snappy压缩数据；  
8.可移植性。  

限制:  
1.非关系型数据模型（NoSQL），不支持sql语句，也不支持索引；  
2.一次只允许一个进程访问一个特定的数据库；  
3.没有内置的C/S架构，但开发者可以使用LevelDB库自己封装一个server。  

整体架构：LevelDB作为存储系统，数据记录的存储介质包括内存以及磁盘文件，如果像上面说的，当LevelDB运行了一段时间，此时我们给LevelDB进行透视拍照，那么您会看到如图所示:  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex32/1.jpg)  

从图中可以看出，构成LevelDB静态结构的包括六个主要部分：**内存中的MemTable和Immutable MemTable以及磁盘上的几种主要文件：Current文件，Manifest文件，log文件以及SSTable文件**。当然，LevelDB除了这六个主要部分还有一些辅助的文件，但是以上六个文件和数据结构是LevelDB的主体构成元素。  

LevelDB的Log文件和Memtable与Bigtable论文中介绍的是一致的，**当应用写入一条Key:Value记录的时候，LevelDB会先往log文件里写入，成功后将记录插进Memtable中**，这样基本就算完成了写入操作，因为**一次写入操作只涉及一次磁盘顺序写和一次内存写入**，所以这是为何说LevelDB写入速度极快的主要原因。  

**Log文件在系统中的作用主要是用于系统崩溃恢复而不丢失数据**，假如没有Log文件，因为写入的记录刚开始是保存在内存中的，此时如果系统崩溃，内存中的数据还没有来得及Dump到磁盘，所以会丢失数据（Redis就存在这个问题）。为了避免这种情况，LevelDB在写入内存前先将操作记录到Log文件中，然后再记入内存中，这样即使系统崩溃，也可以从Log文件中恢复内存中的Memtable，不会造成数据的丢失。  

**当Memtable插入的数据占用内存到了一个界限后，需要将内存的记录导出到外存文件中，LevelDB会生成新的Log文件和Memtable，原先的Memtable就成为Immutable Memtable**，顾名思义，就是说这个Memtable的内容是不可更改的，只能读不能写入或者删除。新到来的数据被记入新的Log文件和Memtable，LevelDB后台调度会将Immutable Memtable的数据导出到磁盘，形成一个新的SSTable文件。**SSTable就是由内存中的数据不断导出并进行Compaction操作后形成的，而且SSTable的所有文件是一种层级结构，第一层为Level 0，第二层为Level 1，依次类推，层级逐渐增高，这也是为何称之为LevelDB的原因**。  

SSTable中的文件是Key有序的，就是说在文件中小key记录排在大Key记录之前，各个Level的SSTable都是如此，**但是这里需要注意的一点是：Level 0的SSTable文件（后缀为.sst）和其它Level的文件相比有特殊性：这个层级内的.sst文件，两个文件可能存在key重叠**，比如有两个level 0的sst文件，文件A和文件B，文件A的key范围是：{bar, car}，文件B的Key范围是{blue,samecity}，那么很可能两个文件都存在key=”blood”的记录。对于其它Level的SSTable文件来说，则不会出现同一层级内.sst文件的key重叠现象，就是说Level L中任意两个.sst文件，那么可以保证它们的key值是不会重叠的。这点需要特别注意，后面您会看到很多操作的差异都是由于这个原因造成的。  

SSTable中的某个文件属于特定层级，而且其存储的记录是key有序的，那么必然有文件中的最小key和最大key，这是非常重要的信息，LevelDB应该记下这些信息。**Manifest就是干这个的，它记载了SSTable各个文件的管理信息，比如属于哪个Level，文件名称叫啥，最小key和最大key各自是多少**。如图是Manifest所存储内容的示意：  
![图](https://raw.githubusercontent.com/chellyk/Bigdata-experiment/master/ex32/2.jpg)  

图中只显示了两个文件（manifest会记载所有SSTable文件的这些信息），即Level 0的test.sst1和test.sst2文件，同时记载了这些文件各自对应的key范围，比如test.sst1的key范围是“an”到 “banana”，而文件test.sst2的key范围是“baby”到“samecity”，可以看出两者的key范围是有重叠的。  

**Current文件是干什么的呢？这个文件的内容只有一个信息，就是记载当前的manifest文件名**。因为在LevleDb的运行过程中，随着Compaction的进行，SSTable文件会发生变化，会有新的文件产生，老的文件被废弃，Manifest也会跟着反映这种变化，此时往往会新生成Manifest文件来记载这种变化，而Current则用来指出哪个Manifest文件才是我们关心的那个Manifest文件。  

以上介绍的内容就构成了LevelDB的整体静态结构。  

## 32.4 实验步骤  
### 32.4.1 安装leveldb  
[下载链接](https://github.com/google/leveldb/releases)  
这里下载的是1.20版本的tar包。  

安装同样需要编译,编译需要g++,事先先安装好g++,make:  
```
sudo apt-get update
sudo apt-get install g++
sudo apt-get install make
```  

完成后解压tar包至/usr/local/leveldb目录，执行make命令:  
```
root@hadoop-master:/usr/local/leveldb# ls
AUTHORS  CONTRIBUTING.md  LICENSE  Makefile  NEWS  README.md  TODO  build_detect_platform  db  doc  helpers  include  issues  port  table  util
root@hadoop-master:/usr/local/leveldb# make
```  

编译完成后:  
```
root@hadoop-master:/usr/local/leveldb# ls
AUTHORS          LICENSE   NEWS       TODO             build_detect_platform  doc      include  out-shared  port   util
CONTRIBUTING.md  Makefile  README.md  build_config.mk  db                     helpers  issues   out-static  table
```  
动态库和静态库分别在 out-shared，out-static下  

之后只有动态库需要安装，静态库在你编译的时候直接链接即可:  
```
# cp leveldb header file
sudo cp -r usr/local/leveldb/include/ /usr/include/
     
# cp lib to /usr/lib/
sudo cp usr/local/leveldb/out-shared/libleveldb.so.1.20 /usr/lib/
     
# create link
sudo ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so.1
sudo ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so
     
# update lib cache
sudo ldconfig
```  

完成后:  
```
ls /usr/lib/libleveldb.so*
# 显示下面 3 个文件即安装成功
/usr/lib/libleveldb.so.1.20
/usr/lib/libleveldb.so.1
/usr/lib/libleveldb.so
```  

``` 
root@hadoop-master:/usr/local/leveldb/out-shared# ls /usr/lib/libleveldb.so*
/usr/lib/libleveldb.so  /usr/lib/libleveldb.so.1  /usr/lib/libleveldb.so.1.20
```
  
### 32.4.2 使用leveldb  
在leveldb安装目录下创建一个code的文件夹作为代码编写的目录  
```
root@hadoop-master:/usr/local/leveldb# mkdir code
root@hadoop-master:/usr/local/leveldb# cd code/
```

利用vim编写leveldb.cpp代码:  
```
root@hadoop-master:/usr/local/leveldb/code# vim leveldb.cpp
```  

完整代码:  
```
#include <iostream>
#include <string>
#include <assert.h>
#include "leveldb/db.h"
using namespace std;
int main(void)
{
    leveldb::DB *db;
    leveldb::Options options;
    options.create_if_missing = true;

    leveldb::Status status = leveldb::DB::Open(options,"./test_level_db", &db);
    assert(status.ok());
    string key = "weather";
    string value = "clearday";

    status = db->Put(leveldb::WriteOptions(), key, value);
    assert(status.ok());

    status = db->Get(leveldb::ReadOptions(), key, &value);
    assert(status.ok());
    cout<<"value :"<<value<<endl;

    status = db->Delete(leveldb::WriteOptions(), key);
    assert(status.ok());
    status = db->Get(leveldb::ReadOptions(),key, &value);
    if(!status.ok()) {
        cerr<<key<<" "<<status.ToString()<<endl;
    } else {
        cout<<key<<"==="<<value<<endl;
    }

    delete db;
    return 0;
}
```  

编写完代码后编译:  
```
root@hadoop-master:/usr/local/leveldb/code# g++ -o leveldb leveldb.cpp ../out-static/libleveldb.a -lpthread -I../include
```
编译完后会生成文件leveldb:  
```
root@hadoop-master:/usr/local/leveldb/code# ls
leveldb  leveldb.cpp 
```

### 32.4.3 代码解释:  
(1)打开数据库连接:  
```
leveldb::Status status = leveldb::DB::Open(options,"./test_level_db", &db);
assert(status.ok());
```  
之后会发现在code目录下创建了test_level_db  

(2)写入数据  
```
string key = "weather";
string value = "clearday";

status = db->Put(leveldb::WriteOptions(), key, value);
assert(status.ok());
```  

(3)读取数据  
```
status = db->Get(leveldb::ReadOptions(), key, &value);   
assert(status.ok());   
cout<<"value :"<<value<<endl;
```  

(4)删除数据  
```
status = db->Delete(leveldb::WriteOptions(), key);
assert(status.ok());
status = db->Get(leveldb::ReadOptions(),key, &value);
if(!status.ok()) {
    cerr<<key<<"   "<<status.ToString()<<endl;
} else {
    cout<<key<<"==="<<value<<endl;
} 
```  

(5)关闭连接  
```
delete db;
```

## 32.5 实验结果  
输入 ./leveldb 运行程序查看结果:  
```
root@hadoop-master:/usr/local/leveldb/code# ./leveldb 
value :clearday
weather NotFound: 
root@hadoop-master:/usr/local/leveldb/code# ls
leveldb  leveldb.cpp  test_level_db
root@hadoop-master:/usr/local/leveldb/code# ls test_level_db/
000003.log  CURRENT  LOCK  LOG  MANIFEST-000002
```



