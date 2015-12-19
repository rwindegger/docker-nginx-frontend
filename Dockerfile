FROM ubuntu:14.04
MAINTAINER Rene Windegger <rene@windegger.wtf>
COPY scripts /opt/scripts/

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

RUN cd /opt/scripts \ 
 && ./installlibmaxminddb.sh

RUN cd /opt/scripts \
 && ./installnginx.sh

# Configure Nginx and apply fix for long server names
RUN echo "daemon off;" >> /opt/nginx/conf/nginx.conf \
 && sed -i 's/^http {/&\n    servernames_hash_bucket_size 128;/g' /opt/nginx/conf/nginx.conf

# Install Forego
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

WORKDIR /opt/

ENV DOCKER_HOST unix:///tmp/docker.sock

ENTRYPOINT ["/opt/scripts/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
