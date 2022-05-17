#/bin/bash

wget -4 http://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-minirootfs-3.15.4-x86_64.tar.gz
mkdir alpine-minirootfs
tar -C ./alpine-minirootfs -xf alpine-minirootfs-3.15.4-x86_64.tar.gz
wget -4 https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.40.tar.xz
tar -xf linux-5.15.40.tar.xz

ln -s linux-5.15.40 linux
