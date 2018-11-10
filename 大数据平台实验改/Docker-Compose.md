# Docker-Compose
```
version: '2'
services:
  spark-slave1:
    image: chellyk:latest
    container_name: hadoop-slave1
    hostname: hadoop-slave1
    volumes:
      - "./volume/hadoop/logs/slave1:/usr/local/hadoop/logs/"
      - "./volume/spark/logs/slave1:/usr/local/spark/logs/"
    networks:
      spark:
        aliases:
          - hadoop-slave1
    tty: true
 
  spark-slave2:
    image: chellyk:latest
    container_name: hadoop-slave2
    hostname: hadoop-slave2
    volumes:
      - "./volume/hadoop/logs/slave2:/usr/local/hadoop/logs/"
      - "./volume/spark/logs/slave2:/usr/local/spark/logs/"  
    networks:
      spark:
        aliases:
          - hadoop-slave2
    tty: true

  mysql:
    image: mysql:5.7.21
    volumes:
      - "./volume/mysql:/var/lib/mysql"
    container_name: mysql
    hostname: mysql
    networks:
      - spark
    environment:
      - MYSQL_ROOT_PASSWORD=hadoop
    tty: true

  spark-master:
    image: chellyk-master:latest
    ports:
      - "50070:50070"
      - "8088:8088"
      - "8080:8080"
      - "8042:8042"
    volumes:
      - "./volume/hadoop/logs/master:/usr/local/hadoop/logs/"
      - "./volume/spark/logs/master:/usr/local/spark/logs/"
      - "./volume/code:/code"
    container_name: hadoop-master
    hostname: hadoop-master
    links:
      - spark-slave1
      - spark-slave2
      - mysql
    networks:
      spark:
        aliases:
          - hadoop-master
    tty: true

networks:
  spark:
```  

chellyk镜像是spark镜像

chellyk-master 多装了hive, compose文件中也多了mysql容器，替代hive的derby存储元数据。






