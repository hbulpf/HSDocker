#hs_base:ubuntu-16.04
docker tag hs_base:ubuntu-16.04 202.116.46.215/hsdocker2019/hs_base:ubuntu-16.04
docker push 202.116.46.215/hsdocker2019/hs_base:ubuntu-16.04

#hs_base:base-notebook
docker tag jupyter/base-notebook:59b402ce701d 202.116.46.215/hsdocker2019/
hs_base-notebook:v1.0
docker push 202.116.46.215/hsdocker2019/hs_base-notebook:v1.0

#tensorflow:1.12.0-gpu-py3
docker tag tensorflow/tensorflow:1.12.0-gpu-py3 202.116.46.215/hsdocker2019/tensorflow:1.12.0-gpu-py3 
docker push 202.116.46.215/hsdocker2019/tensorflow:1.12.0-gpu-py3

#tensorflow:1.12.0-py3
docker tag tensorflow/tensorflow:1.12.0-py3 202.116.46.215/hsdocker2019/tensorflow:1.12.0-py3
docker push 202.116.46.215/hsdocker2019/tensorflow:1.12.0-py3

#tensorflow:1.12.0-gpu
docker tag tensorflow/tensorflow:1.12.0-gpu 202.116.46.215/hsdocker2019/tensorflow:1.12.0-gpu
docker push 202.116.46.215/hsdocker2019/tensorflow:1.12.0-gpu

#tensorflow:1.12.0
docker tag tensorflow/tensorflow:1.12.0 202.116.46.215/hsdocker2019/tensorflow:1.12.0
docker push 202.116.46.215/hsdocker2019/tensorflow:1.12.0

#hs_plate-dection:py2_cpu-v1.0
docker tag hs_plate-dection:py2_cpu-v1.0 202.116.46.215/hsdocker2019/hs_plate-dection:py2_cpu-v1.0
docker push 202.116.46.215/hsdocker2019/hs_plate-dection:py2_cpu-v1.0

#hs_plate-dection:py2_gpu-v1.0
docker tag hs_plate-dection:py2_gpu-v1.0 202.116.46.215/hsdocker2019/hs_plate-dection:py2_gpu-v1.0
docker push 202.116.46.215/hsdocker2019/hs_plate-dection:py2_gpu-v1.0

#oraclelinux:7
docker tag oraclelinux:7 202.116.46.215/hsdocker2019/oraclelinux:7
docker push 202.116.46.215/hsdocker2019/oraclelinux:7

#python-conda-2.7:v1.0
docker tag python-conda-2.7:v1.0 202.116.46.215/hsdocker2019/python-conda-2.7:v1.0
docker push 202.116.46.215/hsdocker2019/python-conda-2.7:v1.0

#python-conda-3:v1.0
docker tag python-conda-3:v1.0 202.116.46.215/hsdocker2019/python-conda-3:v1.0
docker push 202.116.46.215/hsdocker2019/python-conda-3:v1.0

#hs_nvidia-cuda:9.0-base-ubuntu16.04
docker tag hs_nvidia-cuda:9.0-base-ubuntu16.04  202.116.46.215/hsdocker2019/hs_nvidia-cuda:9.0-base-ubuntu16.04
docker push 202.116.46.215/hsdocker2019/hs_nvidia-cuda:9.0-base-ubuntu16.04

#hs_tensorflow:1.12.0-gpu-py3
docker tag hs_tensorflow:1.12.0-gpu-py3 202.116.46.215/hsdocker2019/hs_tensorflow:1.12.0-gpu-py3
docker push 202.116.46.215/hsdocker2019/hs_tensorflow:1.12.0-gpu-py3

#hs_pytorch:1.0.0-py36
docker tag hs_pytorch:1.0.0-py36 202.116.46.215/hsdocker2019/hs_pytorch:1.0.0-py36
docker push 202.116.46.215/hsdocker2019/hs_pytorch:1.0.0-py36