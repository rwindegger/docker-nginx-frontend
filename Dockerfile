FROM ubuntu:14.04
MAINTAINER Rene Windegger <rene@windegger.wtf>
COPY installserver.sh /opt/scripts/installserver.sh
COPY installlibmaxminddb.sh /opt/scripts/installlibmaxminddb.sh
COPY installnginx.sh /opt/scripts/installnginx.sh

RUN /opt/scripts/installnginx.sh

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
