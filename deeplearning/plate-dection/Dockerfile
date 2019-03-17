FROM ubuntu:17.10

WORKDIR /root/

RUN apt-get update && apt-get install -y wget vim libopencv-dev

RUN wget https://github.com/chellyk/HyperLPR/archive/master.zip &&\
    unzip /root/master.zip &&\
    rm master.zip

RUN chmod +x /root/HyperLPR-master/setup.sh && /root/HyperLPR-master/setup.sh










