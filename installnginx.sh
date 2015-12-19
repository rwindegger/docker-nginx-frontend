#!/bin/bash
NGINX_VERSION=1.9.9
NPS_VERSION=1.9.32.10
NAXSI_VERSION=0.54
CP_VERSION=2.1
mkdir ~/src -p &&
cd ~/src &&
#Download and extract stuff nginx
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz &&
tar -xzf nginx-${NGINX_VERSION}.tar.gz &&

#Download and extract ngx_pagespeed
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip &&
unzip release-${NPS_VERSION}-beta.zip &&
cd ~/src/ngx_pagespeed-release-${NPS_VERSION}-beta/ &&
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz &&
tar -xzf ${NPS_VERSION}.tar.gz && # extracts to psol/
cd ~/src &&

#Download and extract naxsi
wget https://github.com/nbs-system/naxsi/archive/${NAXSI_VERSION}.tar.gz &&
tar -xzf ${NAXSI_VERSION}.tar.gz &&

#Download enhanced memcache
git clone --recursive https://github.com/bpaquet/ngx_http_enhanced_memcached_module.git &&

#Download accept language
git clone --recursive https://github.com/giom/nginx_accept_language_module.git &&

#Download cache purge
git clone --recursive https://github.com/FRiCKLE/ngx_cache_purge.git &&

#Download substitutions
git clone --recursive https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git &&

#Download geoip2
git clone --recursive https://github.com/leev/ngx_http_geoip2_module.git &&

#Download http_accounting
git clone --recursive https://github.com/rwindegger/ngx_http_accounting_module.git &&

#Download testcookie DDoS Mitigation
git clone --recursive https://github.com/kyprizel/testcookie-nginx-module.git &&

# Building nginx
cd ~/src/nginx-${NGINX_VERSION}/ &&
./configure --add-module=${HOME}/src/naxsi-${NAXSI_VERSION}/naxsi_src \
   --add-module=${HOME}/src/ngx_pagespeed-release-${NPS_VERSION}-beta \
   --add-module=${HOME}/src/testcookie-nginx-module \
   --add-module=${HOME}/src/ngx_http_enhanced_memcached_module \
   --add-module=${HOME}/src/nginx_accept_language_module \
   --add-module=${HOME}/src/ngx_cache_purge \
   --add-module=${HOME}/src/ngx_http_substitutions_filter_module \
   --add-module=${HOME}/src/ngx_http_geoip2_module \
   --add-module=${HOME}/src/ngx_http_accounting_module \
   --with-http_auth_request_module \
   --with-http_degradation_module \
   --with-http_perl_module \
   --with-http_gzip_static_module \
   --with-http_gunzip_module \
   --with-http_image_filter_module \
   --with-http_mp4_module \
   --with-http_secure_link_module \
   --with-http_v2_module \
   --with-http_ssl_module \
   --with-http_sub_module \
   --with-http_dav_module \
   --with-http_xslt_module \
   --prefix=/opt/nginx \
   --user=www-data \
   --group=www-data &&

make &&
sudo make install &&
cd ~ && 
sudo rm src -R
