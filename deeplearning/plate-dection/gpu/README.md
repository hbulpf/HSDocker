**构建车牌识别镜像** 使用GPU版本

## 构建镜像
在 [Dockerfile](./Dockerfile) 所在目录下:  
```
docker build -t hs_plate-dection:py2_gpu-v1.0  .
```
> 系统使用python2.7

## 使用
> 在使用前请确保已经安装好相应的[显卡驱动](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)#prerequisites)
```
PWD=~/tensorflow_space
JUPYTER_PORT="64011"
docker run --restart=always --runtime=nvidia -d -p $JUPYTER_PORT:8888 -v $PWD:/root -w /root -m 8g --memory-swap=16g --name=hs_plate-dection_py2_gpu-v1.0 hs_plate-dection:py2_gpu-v1.0
cd $PWD
# git clone https://github.com/hbulpf/HyperLPR.git #如果已经拉取该库，可忽略此步骤
docker exec -it hs_plate-dection_py2_gpu-v1.0 bash
```

进入容器后可以做基本测试，会输出识别字牌的结果
```
cd HyperLPR
python demo.py --detect_path ./dataset/1.jpg
```

注：
1. 如果报语言错误，需修改语言设置，这是因为车牌含有中文
```
export LANG=C.UTF-8
```