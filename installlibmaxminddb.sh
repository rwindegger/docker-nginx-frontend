#!/bin/bash
mkdir ~/src -p &&
cd ~/src &&
#Download libmaxminddb
git clone --recursive https://github.com/maxmind/libmaxminddb.git && 
cd ~/src/libmaxminddb && 
./bootstrap && 
./configure --prefix=/usr/local --exec-prefix=/usr/local && 
make && 
make check && 
sudo make install && 
sudo ldconfig &&
cd ~/src &&
sudo rm libmaxminddb -R &&
sudo mkdir /opt/mmdb -p &&
cd /opt/mmdb &&
sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz &&
sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz &&
sudo gunzip GeoLite2-City.mmdb.gz -q -f &&
sudo gunzip GeoLite2-Country.mmdb.gz -q -f &&
cd ~/ &&
sudo rm src -R
