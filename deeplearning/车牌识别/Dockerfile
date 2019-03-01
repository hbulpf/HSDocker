FROM ubuntu:17.10

WORKDIR /root/

RUN apt-get update && apt-get install -y wget vim libopencv-dev

COPY HyperLPR-master /root/

RUN chmod +x /root/setup.sh && /root/setup.sh










