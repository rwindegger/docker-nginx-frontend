FROM ubuntu:14.04
MAINTAINER Rene Windegger <rene@windegger.wtf>

# Copy base Scripts
COPY scripts /opt/scripts/

# Install dependencies
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
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

# Install nginx
RUN cd /opt/scripts \ 
 && ./installlibmaxminddb.sh \
 && ./installnginx.sh \
 && echo "daemon off;" >> /opt/nginx/conf/nginx.conf \
 && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /opt/nginx/conf/nginx.conf

# Install Forego
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

WORKDIR /opt/scripts/

ENV DOCKER_HOST=unix:///tmp/docker.sock DOCKER_GEN_VERSION=0.4.2

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

EXPOSE 80 443

COPY html /opt/nginx/html

VOLUME /opt/nginx/html /opt/certs

ENTRYPOINT ["/opt/scripts/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
