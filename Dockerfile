FROM debian:jessie
MAINTAINER Rene Windegger <rene@windegger.wtf>

# Install dependencies
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    libgoogle-perftools-dev \
    build-essential \
    ca-certificates \
    dh-autoreconf \
    git \
    libc6 \
    libexpat1 \
    libgd2-xpm-dev \
    libgeoip-dev \
    libpcre3-dev \
    libperl-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    unzip \
    wget \
    zlib1g-dev \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

# Install Forego
RUN wget -P /usr/local/bin https://github.com/jwilder/forego/releases/download/v0.16.1/forego \
 && chmod u+x /usr/local/bin/forego
 
# Setup Environment Variables
ENV DOCKER_GEN_VERSION=0.7.3

# Install Dockergen
RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

# Install certbot
RUN wget -P /usr/local/bin https://dl.eff.org/certbot-auto \
 && chmod a+x /usr/local/bin/certbot-auto
 
# Install libmaxminddb
RUN mkdir ~/src -p \
 && cd ~/src \
 && git clone --recursive https://github.com/maxmind/libmaxminddb.git \
 && cd ~/src/libmaxminddb \
 && ./bootstrap \
 && ./configure --prefix=/usr/local --exec-prefix=/usr/local \
 && make \
 && make check \
 && make install \
 && ldconfig \
 && cd ~/src \
 && rm libmaxminddb -R \
 && mkdir /opt/mmdb -p \
 && cd /opt/mmdb \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz \
 && gunzip GeoLite2-City.mmdb.gz -q -f \
 && gunzip GeoLite2-Country.mmdb.gz -q -f \
 && cd ~/ \
 && rm src -R

# Install nginx
ENV NGINX_VERSION=1.11.6 NPS_VERSION=1.11.33.4 NAXSI_VERSION=0.55.1 CP_VERSION=2.1 NGX_PURGE_VERSION=2.3 RTMP_VERSION=1.1.10 ENHANCED_MEMCACHED_VERSION=0.2 GEOIP2_VERSION=2.0 ACCOUNTING_VERSION=1.0 SUBSTITUTIONS_VERSION=0.6.4

RUN mkdir ~/src -p \
 && cd ~/src \
 && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
 && tar -xzf nginx-$NGINX_VERSION.tar.gz \
 && wget https://github.com/pagespeed/ngx_pagespeed/archive/release-$NPS_VERSION-beta.zip \
 && unzip release-$NPS_VERSION-beta.zip \
 && cd ~/src/ngx_pagespeed-release-$NPS_VERSION-beta/ \
 && wget https://dl.google.com/dl/page-speed/psol/$NPS_VERSION.tar.gz \
 && tar -xzf $NPS_VERSION.tar.gz \
 && cd ~/src \
 && wget https://github.com/nbs-system/naxsi/archive/$NAXSI_VERSION.tar.gz \
 && tar -xzf $NAXSI_VERSION.tar.gz \
 && wget https://github.com/FRiCKLE/ngx_cache_purge/archive/$NGX_PURGE_VERSION.tar.gz \
 && tar -xzf $NGX_PURGE_VERSION.tar.gz \
 && wget https://github.com/arut/nginx-rtmp-module/archive/v$RTMP_VERSION.tar.gz \
 && tar -xzf v$RTMP_VERSION.tar.gz \
 && wget https://github.com/bpaquet/ngx_http_enhanced_memcached_module/archive/v$ENHANCED_MEMCACHED_VERSION.tar.gz \
 && tar -xzf v$ENHANCED_MEMCACHED_VERSION.tar.gz \
 && wget https://github.com/leev/ngx_http_geoip2_module/archive/$GEOIP2_VERSION.tar.gz \
 && tar -xzf $GEOIP2_VERSION.tar.gz \
 && wget https://github.com/Lax/ngx_http_accounting_module/archive/v$ACCOUNTING_VERSION.tar.gz \
 && tar -xzf v$ACCOUNTING_VERSION.tar.gz \
 && wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/v$SUBSTITUTIONS_VERSION.tar.gz \
 && tar -xzf v$SUBSTITUTIONS_VERSION.tar.gz \
 && git clone --recursive https://github.com/giom/nginx_accept_language_module.git \
 && git clone --recursive https://github.com/kyprizel/testcookie-nginx-module.git \
 && git clone --recursive https://github.com/vozlt/nginx-module-vts.git \
 && cd ~/src/nginx-$NGINX_VERSION/ \
 && ./configure \
   --add-module=$HOME/src/naxsi-$NAXSI_VERSION/naxsi_src \
   --add-module=$HOME/src/nginx-module-vts \
   --add-module=$HOME/src/nginx-rtmp-module-$RTMP_VERSION \
   --add-module=$HOME/src/nginx_accept_language_module \
   --add-module=$HOME/src/ngx_cache_purge-$NGX_PURGE_VERSION \
   --add-module=$HOME/src/ngx_http_accounting_module-$ACCOUNTING_VERSION \
   --add-module=$HOME/src/ngx_http_enhanced_memcached_module-$ENHANCED_MEMCACHED_VERSION \
   --add-module=$HOME/src/ngx_http_geoip2_module-$GEOIP2_VERSION \
   --add-module=$HOME/src/ngx_http_substitutions_filter_module-$SUBSTITUTIONS_VERSION \
   --add-module=$HOME/src/ngx_pagespeed-release-$NPS_VERSION-beta \
   --add-module=$HOME/src/testcookie-nginx-module \
   --with-google_perftools_module \
   --with-http_auth_request_module \
   --with-http_dav_module \
   --with-http_degradation_module \
   --with-http_gunzip_module \
   --with-http_gzip_static_module \
   --with-http_image_filter_module \
   --with-http_image_filter_module \
   --with-http_mp4_module \
   --with-http_perl_module \
   --with-http_realip_module \
   --with-http_secure_link_module \
   --with-http_slice_module \
   --with-http_ssl_module \
   --with-http_sub_module \
   --with-http_v2_module \
   --with-http_xslt_module \
   --with-mail \
   --with-mail_ssl_module \
   --with-stream \
   --with-stream_ssl_module \
   --prefix=/opt/nginx \
   --user=www-data \
   --group=www-data \
 && make \
 && make install \
 && cd ~ \
 && cd src \
 && cp naxsi-$NAXSI_VERSION/naxsi_config/naxsi_core.rules /opt/nginx/conf/ \
 && cd ~ \
 && rm src -R \
 && mkdir /opt/nginx/conf/conf.d -p \
 && echo 'daemon off;' >> /opt/nginx/conf/nginx.conf \
 && sed -i 's@^http {@&\n    server_names_hash_bucket_size 128;@g' /opt/nginx/conf/nginx.conf \
 && sed -i '117 a    include /opt/nginx/conf/conf.d/*.conf;' /opt/nginx/conf/nginx.conf

COPY nps.rules /opt/nginx/conf/nps.rules
COPY log.conf /opt/nginx/conf/log.conf

 # Copy base Scripts
COPY scripts /opt/scripts/
WORKDIR /opt/scripts/

COPY html /opt/nginx/html

EXPOSE 80 443
VOLUME /opt/nginx/html /opt/certs /opt/nginx/conf/htpasswd /opt/nginx/conf/vhost.d

ENV DOCKER_HOST=unix:///tmp/docker.sock

ENTRYPOINT ["/opt/scripts/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
