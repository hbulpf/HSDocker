FROM 202.116.46.215/hsdocker2019/oraclelinux:7
MAINTAINER HSDocker
USER root
# configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV CONTAINER_USER lion
ENV CONTAINER_UID 1000
# create conda directory for lion user
RUN mkdir -p /opt/conda && \
    chown lion /opt/conda
USER $CONTAINER_USER
# install conda with python 3
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    echo $(wget --quiet -O - https://repo.continuum.io/miniconda/ \
       | grep -A3 "Miniconda3-latest-Linux-x86_64.sh" \
       | tail -n1 \
       | cut -d\> -f2 \
       | cut -d\< -f1 ) "Miniconda3-latest-Linux-x86_64.sh" | md5sum -c - && \    
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-latest-Linux-x86_64.sh