# 说明
文件记录了在k8s集群上测试hadoop，spark集群的历次变动。  

## 1.v1
直接建立1个master节点的pod和2个slave节点的pod

## 2.v2
在v1的基础上新增加了service

## 3.v3
在v2的基础上，slave节点的部署选择使用StatefulSets. 新增web-service, 通过Nodeport的方式让外部能够访问hadoop,spark集群的web界面


