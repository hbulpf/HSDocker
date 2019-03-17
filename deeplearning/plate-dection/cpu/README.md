**构建车牌识别镜像** 使用CPU 版本

## 构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build -t hs_plate-dection:py2_cpu-v1.0  .
```
> 系统使用python2.7

## 使用
```
PWD=~/tmp
JUPYTER_PORT="64011"
docker run --restart=always --runtime=nvidia -d -p $JUPYTER_PORT:8888 -v $PWD:/root -w /tmp -m 8g --memory-swap=16g --name=hs_plate-dection_py2_cpu-v1.0 hs_plate-dection:py2_cpu-v1.0
cd $PWD
git clone https://github.com/hbulpf/HyperLPR.git #如果已经拉取该库，可忽略此步骤
docker exec -it hs_plate-dection_py2_cpu-v1.0  bash
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