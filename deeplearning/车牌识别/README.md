# 构建车牌识别镜像

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build -t hs_plate-dection:v1.0  .
```

## 2.修改语言环境  
因为涉及到中文，必须修改语言:
```
export LANG=C.UTF-8
source /etc/profile
```

## 3.具体使用
进入/root/HyperLPR-master目录
```
python demo.py --detect_path dataset/1.jpg
```
可以做基本测试，会输出识别字牌的结果






