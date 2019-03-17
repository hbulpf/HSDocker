# 构建车牌识别镜像

## !!现在存在问题，在apt-get install libopencv-dev过程中会报错强制中断

## 1.构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache -t hs_plate-dection:v1.0  .
```

## 2.修改语言环境  
因为涉及到中文，必须修改语言:
```

```

## 3.具体使用
```
PWD=~/tmp
docker run --restart=always -v $PWD:/root -w /tmp -m 8g --memory-swap 16g --name=hs_plate-dection hs_plate-dection:v1.0
docker exec -it hs_plate-dection:v1.0 bash
```
进入/root/HyperLPR目录
```
sh /root/HyperLPR/setup.sh
```

可以做基本测试，会输出识别字牌的结果
```
python demo.py --detect_path dataset/1.jpg
```

