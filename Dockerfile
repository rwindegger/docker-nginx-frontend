FROM ubuntu:14.04
MAINTAINER Rene Windegger <rene@windegger.wtf>

ENV DOCKER_HOST=unix:///tmp/docker.sock DOCKER_GEN_VERSION=0.4.2 NGINX_VERSION=1.9.9 NPS_VERSION=1.10.33.2 NAXSI_VERSION=0.54 CP_VERSION=2.1

# Copy base Scripts
COPY scripts /opt/scripts/

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
 && sudo ldconfig \
 && cd ~/src \
 && sudo rm libmaxminddb -R \
 && sudo mkdir /opt/mmdb -p \
 && cd /opt/mmdb \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz \
 && gunzip GeoLite2-City.mmdb.gz -q -f \
 && gunzip GeoLite2-Country.mmdb.gz -q -f \
 && cd ~/ \
 && rm src -R

# Install nginx
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
 && git clone --recursive https://github.com/FRiCKLE/ngx_cache_purge.git \
 && git clone --recursive https://github.com/arut/nginx-rtmp-module.git \
 && git clone --recursive https://github.com/bpaquet/ngx_http_enhanced_memcached_module.git \
 && git clone --recursive https://github.com/giom/nginx_accept_language_module.git \
 && git clone --recursive https://github.com/gnosek/nginx-upstream-fair.git \
 && git clone --recursive https://github.com/kyprizel/testcookie-nginx-module.git \
 && git clone --recursive https://github.com/leev/ngx_http_geoip2_module.git \
 && git clone --recursive https://github.com/rwindegger/ngx_http_accounting_module.git \
 && git clone --recursive https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git \
 && git clone --recursive https://github.com/vozlt/nginx-module-vts.git \
 && cd ~/src/nginx-$NGINX_VERSION/ \
 && ./configure \
   --add-module=$HOME/src/naxsi-$NAXSI_VERSION/naxsi_src \
   --add-module=$HOME/src/nginx-module-vts \
   --add-module=$HOME/src/nginx-rtmp-module \
   --add-module=$HOME/src/nginx-upstream-fair \
   --add-module=$HOME/src/nginx_accept_language_module \
   --add-module=$HOME/src/ngx_cache_purge \
   --add-module=$HOME/src/ngx_http_accounting_module \
   --add-module=$HOME/src/ngx_http_enhanced_memcached_module \
   --add-module=$HOME/src/ngx_http_geoip2_module \
   --add-module=$HOME/src/ngx_http_substitutions_filter_module \
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
 && rm src -R \
 && mkdir /opt/nginx/conf/conf.d -p \
 && echo 'daemon off;' >> /opt/nginx/conf/nginx.conf \
 && sed -i 's@^http {@&\n    server_names_hash_bucket_size 128;@g' /opt/nginx/conf/nginx.conf

# Install Forego
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

WORKDIR /opt/scripts/

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

EXPOSE 80 443

COPY html /opt/nginx/html

VOLUME /opt/nginx/html /opt/certs

ENTRYPOINT ["/opt/scripts/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
