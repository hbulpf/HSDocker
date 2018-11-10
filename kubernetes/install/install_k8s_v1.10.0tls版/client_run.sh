#!/bin/bash
cat >/etc/hosts <<EOM
container-getty@.service                initrd.target                      quotaon.service                    sockets.target.wants                           systemd-rfkill@.service
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
193.112.177.239 master
112.74.186.129 node1
EOM

cd ./client
./run.sh