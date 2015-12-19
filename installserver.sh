#!/bin/bash
sudo apt-get install build-essential zlib1g-dev unzip libperl-dev libssl-dev libc6 libexpat1 libgd2-xpm-dev libgeoip-dev libpcre3-dev &&
./installlibmaxminddb.sh &&
./installnginx.sh
