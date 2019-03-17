**构建车牌识别镜像**

## 构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build --no-cache -t hs_plate-dection:v1.0  .
```

## 使用
```
PWD=~/tmp
docker run --restart=always -v $PWD:/root -w /tmp -m 8g --memory-swap 16g --name=hs_plate-dection hs_plate-dection:v1.0
cd $PWD
git clone https://github.com/hbulpf/HyperLPR.git #如果已经拉取该库，可忽略此步骤
docker exec -it hs_plate-dection:v1.0 bash
```

进入容器后可以做基本测试，会输出识别字牌的结果
```
python demo.py --detect_path ./HyperLPR/dataset/1.jpg
```

注：
1. 如果报语言错误，需修改语言设置，这是因为车牌含有中文
```
export LANG=C.UTF-8
```