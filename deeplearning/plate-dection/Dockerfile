FROM tensorflow/tensorflow:1.12.0

WORKDIR /root/

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y wget vim libopencv-dev python-numpy python-scipy python-matplotlib

RUN pip install pillow -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install scikit-image -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install opencv-python -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install keras -i https://pypi.tuna.tsinghua.edu.cn/simple









