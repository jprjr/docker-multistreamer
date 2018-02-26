FROM alpine:3.7

ARG S6_OVERLAY_VER=1.21.2.2
ARG OPENRESTY_VER=1.13.6.1
ARG NGINX_RTMP_VER=1.2.1
ARG LUAROCKS_VER=2.4.3
ARG MULTISTREAMER_VER=master
ARG SOCKEXEC_VER=2.0.3

RUN apk add --no-cache \
    bash \
    gcc \
    make \
    musl-dev \
    linux-headers \
    gd-dev \
    geoip-dev \
    libxml2-dev \
    libxslt-dev \
    libressl-dev \
    paxmark \
    pcre-dev \
    yaml-dev \
    yaml \
    perl-dev \
    pkgconf \
    zlib-dev \
    curl \
    git \
    unzip \
    dnsmasq \
    ffmpeg \
    lua5.1-dev \
    lua5.1 \
    pcre \
    libressl2.6-libssl \
    libressl2.6-libtls \
    libressl2.6-libcrypto \
    ca-certificates \
    postgresql-client \
    zlib

RUN mkdir /tmp/openresty-build && \
  cd /tmp/openresty-build && \
  curl -R -L -o s6-overlay-amd64.tar.gz \
    https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VER/s6-overlay-amd64.tar.gz  && \
  curl -R -L -o sockexec-x86_64-linux-musl.tar.gz \
    https://github.com/jprjr/sockexec/releases/download/$SOCKEXEC_VER/sockexec-x86_64-linux-musl.tar.gz && \
  curl -R -L -o openresty-$OPENRESTY_VER.tar.gz \
    https://openresty.org/download/openresty-$OPENRESTY_VER.tar.gz && \
  curl -R -L -o nginx-rtmp-module-$NGINX_RTMP_VER.tar.gz \
    https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_VER.tar.gz && \
  curl -R -L -o luarocks-$LUAROCKS_VER.tar.gz \
    http://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS_VER.tar.gz && \
  tar xzf openresty-$OPENRESTY_VER.tar.gz && \
  tar xzf nginx-rtmp-module-$NGINX_RTMP_VER.tar.gz && \
  tar xzf luarocks-$LUAROCKS_VER.tar.gz && \
  tar xzf s6-overlay-amd64.tar.gz -C / && \
  tar xzf sockexec-x86_64-linux-musl.tar.gz -C /usr && \
  cd openresty-$OPENRESTY_VER && \
  ( \
    ./configure \
      --prefix=/opt/openresty \
      --with-threads \
      --with-file-aio \
      --with-ipv6 \
      --with-http_ssl_module \
      --with-pcre \
      --with-pcre-jit \
      --with-stream \
      --with-stream_ssl_module \
      --add-module=../nginx-rtmp-module-$NGINX_RTMP_VER && \
    make  && \
    make install \
  ) && \
  cd /tmp/openresty-build/luarocks-$LUAROCKS_VER && \
  ./configure \
    --prefix=/opt/luarocks \
    --with-lua-include=$(pkg-config --variable=includedir lua5.1) && \
  make && \
  make build && \
  make install && \
  cd / && \
  rm -rf /tmp/openresty-build

RUN  mkdir /etc/htpasswd-auth-server && \
  mkdir /etc/redis-auth-server && \
  adduser -h /home/redisauth -g redisauth -s /sbin/nologin -S -D redisauth && \
  cd /home/redisauth && \
  curl -R -L -o redis-auth-server-master.tar.gz \
    https://github.com/jprjr/redis-auth-server/archive/master.tar.gz && \
  tar xzf redis-auth-server-master.tar.gz && \
  mv redis-auth-server-master/* . && \
  rm -rf redis-auth-server-master && \
  chown -R redisauth:nogroup . && \
  ln -sf /home/multistreamer/lua_modules ./lua_modules && \
  rm -rf ./etc && \
  ln -sf /etc/redis-auth-server ./etc && \
  adduser -h /home/htpasswdauth -g htpasswdauth -s /sbin/nologin -S -D htpasswdauth && \
  cd /home/htpasswdauth && \
  curl -R -L -o htpasswd-auth-server-master.tar.gz \
    https://github.com/jprjr/htpasswd-auth-server/archive/master.tar.gz && \
  tar xzf htpasswd-auth-server-master.tar.gz && \
  mv htpasswd-auth-server-master/* . && \
  rm -rf htpasswd-auth-server-master && \
  chown -R htpasswdauth:nogroup . && \
  ln -sf /home/multistreamer/lua_modules ./lua_modules && \
  rm -rf ./etc && \
  ln -sf /etc/htpasswd-auth-server ./etc

RUN adduser -h /home/multistreamer -g multistreamer -s /sbin/nologin -S -D multistreamer && \
  cd /home/multistreamer && \
  rm -rf ./* && \
  git clone https://github.com/jprjr/multistreamer.git . && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-exec && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-jit-uuid && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lua-resty-http && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lapis && \
  /opt/luarocks/bin/luarocks --tree lua_modules install etlua && \
  /opt/luarocks/bin/luarocks --tree lua_modules install luaposix && \
  /opt/luarocks/bin/luarocks --tree lua_modules install luafilesystem && \
  /opt/luarocks/bin/luarocks --tree lua_modules install whereami && \
  /opt/luarocks/bin/luarocks --tree lua_modules install luacrypto && \
  /opt/luarocks/bin/luarocks --tree lua_modules install lyaml && \
  /opt/luarocks/bin/luarocks --tree lua_modules install redis-lua && \
  /opt/luarocks/bin/luarocks --tree lua_modules install md5 && \
  chown -R multistreamer:nogroup . && \
  mkdir /etc/multistreamer && \
  mkdir -p /var/log/multistreamer && \
  chown nobody:nogroup /var/log/multistreamer

COPY rootfs /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

ENTRYPOINT ["/init"]

EXPOSE 1935 6667 8081
