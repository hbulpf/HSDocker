# Hive本地模式部署

实验十～实验十二用的都是Hive的内嵌模式，这次采用Hive的本地模式，即用mysql代替derby存储元数据。   

## 1.启动hadoop集群  
按照hadoop集群demo2,正常运行起hadoop集群。

## 2.安装Hive  
参考实验十，在master节点先部署hive的内嵌模式。

## 3.安装mysql  
镜像用的是ubuntu14.04，安装mysql比较简单:  
```
sudo apt-get update
sudo apt-get install mysql-server mysql-client
```  
安装过程会要求你设置root账户的密码。  

安装完后登录mysql:  
```
root@hadoop-master:~# mysql -u root -p
Enter password: 
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)
```  
会有个莫名奇妙的报错，重启mysql后可以解决:  
```
root@hadoop-master:~# sudo service mysql restart
root@hadoop-master:~# mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 5.5.60-0ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```  

创建一个用户并赋予所有权限：  
```
mysql> create user 'hive' identified by 'hive';
Query OK, 0 rows affected (0.00 sec)

mysql> grant all on *.* to 'hive'@'%' identified by 'hive' with grant option;
Query OK, 0 rows affected (0.00 sec)

mysql> grant all on *.* to 'hive'@'localhost' identified by 'hive' with grant option;
Query OK, 0 rows affected (0.01 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
```  

这里我们创建了用户hive,密码为hive。  

接着以hive用户登录，创建数据库hive:  
```
root@hadoop-master:~# mysql -u hive -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 45
Server version: 5.5.60-0ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database hive;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| hive               |
| mysql              |
| performance_schema |
+--------------------+
4 rows in set (0.00 sec)
```  

## 4.完成hive跟mysql的连接:  
(1) 修改hive-site.xml配置文件:  
进入/usr/local/hive/conf目录，修改**hive-site.xml**:  
```
root@hadoop-master:/usr/local/hive/conf# ls
beeline-log4j.properties.template  hive-default.xml.template  hive-env.sh.template                 hive-log4j.properties.template  metastore_db
derby.log                          hive-env.sh                hive-exec-log4j.properties.template  ivysettings.xml
root@hadoop-master:/usr/local/hive/conf# cp hive-default.xml.template hive-site.xml
root@hadoop-master:/usr/local/hive/conf# vi hive-site.xml 
```  

hive-site.xml文件内容很多，我们要找到以下内容并修改:  
(学会用vi,vim的查找功能，在命令模式下输入?javax.jdo.option.ConnectionURL即可查找)  
A.修改javax.jdo.option.ConnectionURL属性:
```xml
<property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://localhost/hive?createDatabaseIfNotExist=true</value>
    <description>JDBC connect string for a JDBC metastore</description>
</property>
```  

B.修改javax.jdo.option.ConnectionDriverName属性:
```xml
<property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
    <description>Driver class name for a JDBC metastore</description>
</property>
```  

C.修改javax.jdo.option.ConnectionUserName属性。即刚创建的用户名。
```xml
<property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>hive</value>
    <description>Username to use against metastore database</description>
</property>
```  

D、修改javax.jdo.option.ConnectionPassword属性。即刚创建的用户名的密码。  
```xml
<property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>hive</value>
    <description>password to use against metastore database</description>
</property>
```  

E、**添加**如下属性hive.metastore.local：  
```xml
<property>
    <name>hive.metastore.local</name>
    <value>true</value>
    <description>controls whether to connect to remove metastore server or open a new metastore server in Hive Client JVM</description>
</property>
```  

F.修改hive.server2.logging.operation.log.location属性，因为默认的配置里没有指定具体的路径。  
```xml
<property>
    <name>hive.server2.logging.operation.log.location</name>
    <value>/tmp/hive/operation_logs</value>
    <description>Top level directory where operation logs are stored if logging functionality is enabled</descripti     on>
</property>
```  

G.修改hive.exec.local.scratchdir属性。
```xml
<property>
    <name>hive.exec.local.scratchdir</name>
    <value>/tmp/hive</value>
    <description>Local scratch space for Hive jobs</description>
</property>
```  

H、修改hive.downloaded.resources.dir属性。  
```xml
<property>
    <name>hive.downloaded.resources.dir</name>
    <value>/tmp/hive/resources</value>
    <description>Temporary local directory for added resources in the remote file system.</description>
</property> 
```  

I、修改属性hive.querylog.location属性。  
```xml
<property>
    <name>hive.querylog.location</name>
    <value>/tmp/hive/querylog</value>
    <description>Location of Hive run time structured log file</description>
</property>
```

(2)配置hive的log4j配置文件  
``root@hadoop-master:/usr/local/hive/conf# cp hive-log4j.properties.template hive-log4j.properties``  

(3)将MySQL的**JDBC驱动包**拷贝到hive的安装目录中。
[驱动包下载][1] 
[1]: https://downloads.mysql.com/archives/c-j/  
这次我下的是5.1.32的版本，下载的压缩包解压后能找到jar包，将jar包拷贝至/usr/local/hive/lib目录下：  
``sudo docker cp mysql-connector-java-5.1.32-bin.jar hadoop-master:/usr/local/hive/lib``1  
这里我是主机将jar包拷贝至master节点  

(4)将hive下的jline-2.12.jar拷贝至**/usr/local/hadoop/share/hadoop/yarn/lib**目录下:  
jline-2.12.jar在/usr/local/hive/lib目录下:  
```
root@hadoop-master:/usr/local/hive/lib# cp jline-2.12.jar /usr/local/hadoop/share/hadoop/yarn/lib
```  

## 5.验证部署是否成功
先看能不能成功进入hive:  
```
root@hadoop-master:/usr/local/hive/conf# hive              

Logging initialized using configuration in file:/usr/local/hive/conf/hive-log4j.properties
hive> create table test(a string , b int);
OK
Time taken: 1.267 seconds
hive> show tables;
OK
test
Time taken: 0.079 seconds, Fetched: 1 row(s)
hive> quit;
```
成功则创建表test。  

接着我们进行mysql查看:  
```
root@hadoop-master:/usr/local/hive/conf# mysql -u hive -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 78
Server version: 5.5.60-0ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use hive;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select TBL_ID, CREATE_TIME, DB_ID, OWNER, TBL_NAME,TBL_TYPE from TBLS;
+--------+-------------+-------+-------+----------+---------------+
| TBL_ID | CREATE_TIME | DB_ID | OWNER | TBL_NAME | TBL_TYPE      |
+--------+-------------+-------+-------+----------+---------------+
|      1 |  1531803304 |     1 | root  | test     | MANAGED_TABLE |
+--------+-------------+-------+-------+----------+---------------+
1 row in set (0.00 sec)
```
进入hive数据库，查找表，我们成功找到刚在hive里创建的test表，证明连接已经成功。  

原先的内嵌模式，使用hive每次quit后，之前的操作，像是建表等操作留下的数据均不会保留，这次用本地模式后，创建过的表quit后再进入依然还在。
