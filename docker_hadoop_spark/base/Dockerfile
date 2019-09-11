FROM ubuntu:17.10
# install openssh-server python2.7 openssh wget vim openjdk-8-jdk 
RUN apt-get update && \
    apt-get install -y && \
    python2.7 openssh-server wget vim openjdk-8-jdk
# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys